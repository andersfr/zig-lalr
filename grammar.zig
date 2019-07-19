const std = @import("std");
const warn = std.debug.warn;
const assert = std.debug.assert;

const FlatHash = @import("flat_hash/flat_hash.zig");
const IndexMap = @import("flat_hash/index_map.zig");

usingnamespace FlatHash;
usingnamespace IndexMap;

const YesNoMaybe = enum { Maybe = 0, Yes = 1, No = 2 };

const ArrayList = std.ArrayList;

fn varToStr(b: var) []const u8 {
    switch(@typeOf(b)) {
        bool => {
            if(b) return "+";
            return "-";
        },
        YesNoMaybe => switch(b) {
            .Yes => return "+",
            .No => return "-",
            .Maybe => return "?",
        },
        else => unreachable,
    }
}

pub const Production = struct {
    terminal: []const u8,
    symbols: ArrayList([]const u8),
    symbol_ids: []usize = [0]usize{},
    terminal_id: usize = 0,
    nullable: YesNoMaybe = .Maybe,

    const Self = @This();

    pub fn init(allocator: *std.mem.Allocator, terminal: []const u8) Self {
        // Only store allocator in the ArrayList and pull the pointer when needed
        return Self{ .terminal = terminal, .symbols = ArrayList([]const u8).init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        if(self.symbol_ids.len > 0) {
            self.symbols.allocator.free(self.symbol_ids);
        }
        self.symbols.deinit();
    }

    pub fn append(self: *Self, symbol: []const u8) !void {
        try self.symbols.append(symbol);
    }

    pub fn finalize(self: *Self) !void {
        // Check if production is nullable
        if(self.symbols.len == 0) {
            // Traditionally represented in litterature as the greek Epsilon
            try self.append("$epsilon");
            self.nullable = .Yes;

        }
        self.symbol_ids = try self.symbols.allocator.alloc(usize, self.symbols.len);
    }

    pub fn debug(self: Self, grammar: *Grammar) void {
        if(grammar.isSpecial(self.terminal_id)) {
            warn("{} \x1b[35m{}\x1b[0m[{}] <-", varToStr(self.nullable), self.terminal, self.terminal_id);
        }
        else {
            warn("{} \x1b[34m{}\x1b[0m[{}] <-", varToStr(self.nullable), self.terminal, self.terminal_id);
        }
        for(self.symbol_ids) |id,i| {
            if(grammar.isSpecial(id)) {
                warn(" \x1b[35m{}\x1b[0m[{}]", self.symbols.at(i), id);
            }
            else if(grammar.isTerminal(id)) {
                warn(" \x1b[34m{}\x1b[0m[{}]", self.symbols.at(i), id);
            }
            else {
                warn(" \x1b[90m{}\x1b[0m[{}]", self.symbols.at(i), id);
            }
        }
        warn("\n");
    }
};

pub const Grammar = struct {
    allocator: *std.mem.Allocator,
    productions: ArrayList(*Production),
    names_index_map: StringIndexMap(usize),
    epsilon_index: usize = 0,

    const Self = @This();

    pub fn init(allocator: *std.mem.Allocator, name: []const u8) Self {
        return Self{ 
            .allocator = allocator, 
            .productions = ArrayList(*Production).init(allocator),
            .names_index_map = StringIndexMap(usize).init(allocator),
            };
    }

    pub fn deinit(self: *Self) void {
        // Cleanup productions and free them
        var it = self.productions.iterator();
        while(it.next()) |production| {
            production.deinit();
            self.allocator.destroy(production);
        }
        // Cleanup the list holding the productions
        self.productions.deinit();
        // Cleanup the index map
        self.names_index_map.deinit();
    }

    pub fn append(self: *Self, production: *Production) !void {
        // The first terminal encountered is considered the initial production
        if (self.productions.len == 0)
        // Augment the grammar with rule: $accept <- `initial` $eof
            try self.augment(production.terminal);

        // Allow the production to set internal fields
        try production.finalize();

        // Append the production
        try self.productions.append(production);
    }

    pub fn finalize(self: *Self) !void {
        // Iterate all productions and add their terminal symbol to the index mapping
        var it = self.productions.iterator();
        while(it.next()) |production| {
            production.terminal_id = try self.names_index_map.insert(production.terminal);
        }
        // Explicitly add epsilon symbol to make it the first non-terminal symbol indexed
        self.epsilon_index = try self.names_index_map.insert("$epsilon");
        // Explicitly add eof symbol to make it the second non-terminal symbol indexed
        _ = try self.names_index_map.insert("$eof");

        // Iterate again but this time add the symbols to get non-terminals into the mapping
        it.reset();
        while(it.next()) |production| {
            var sit = production.symbols.iterator();
            var i: usize = 0;
            while(sit.next()) |symbol| : (i += 1)  {
                // Store the mapped ids to avoid dealing with strings all together
                const symbol_id = try self.names_index_map.insert(symbol);
                production.symbol_ids[i]  = symbol_id;
                // Productions with non-terminals cannot be nullable
                if(self.isNonterminal(symbol_id) and symbol_id != self.epsilon_index) {
                    production.nullable = .No;
                }
            }
        }

        // Calculate which productions and terminals have the nullability property
        try nullabilityPass(self);

        // TODO: remove debugging
        it.reset();
        while(it.next()) |production| {
            production.debug(self);
        }
    }

    pub fn terminalCount(self: Self) usize {
        return self.epsilon_index;
    }

    fn augment(self: *Self, name: []const u8) !void {
        // Augmenting a grammar means that it gets the sepcial rule: $accept <- `initial` $eof
        var production = try self.allocator.create(Production);
        production.* = Production.init(self.allocator, "$accept");
        errdefer production.deinit();

        // Build the production
        try production.append(name);
        try production.append("$eof");
        try production.finalize();

        // Append it to the grammar
        try self.productions.append(production);
    }

    fn isTerminal(self: Self, index: usize) bool {
        return index < self.epsilon_index;
    }

    fn isNonterminal(self: Self, index: usize) bool {
        return index >= self.epsilon_index;
    }

    fn isSpecial(self: Self, index: usize) bool {
        // $accept, $epsilon, $eof
        return index == 0 or index == self.epsilon_index or index == self.epsilon_index+1;
    }
};

fn nullabilityPass(grammar: *Grammar) !void {
    // Allocate temporary memory for performing the calculation
    var terminal_nullability: []YesNoMaybe = try grammar.allocator.alloc(YesNoMaybe, grammar.terminalCount()+1);
    defer grammar.allocator.free(terminal_nullability);

    // Initialy every terminal is unknown
    for(terminal_nullability) |*tn| {
        tn.* = .Maybe;
    }
    // Consider $epsilon as nullable (by definition)
    terminal_nullability[grammar.epsilon_index] = .Yes;

    // Trivial implementation loops over all productions until no further progress can be made
    var changed: bool = false;
    while(true) : (changed = false) {
        var pit = grammar.productions.iterator();
        while(pit.next()) |production| {
            // Production is known to be nullable, e.g. trivial or already computed
            if(production.nullable == .Yes) {
                if(terminal_nullability[production.terminal_id] != .Yes) {
                    terminal_nullability[production.terminal_id] = .Yes;
                    changed = true;
                }
                continue;
            }
            // Production is known not to be nullable, e.g. contains non-terminals
            else if(production.nullable == .No) {
                continue;
            }
            // Check if production is made entirely of nullable terminals
            var early_exit: bool = false;
            for(production.symbol_ids) |symbol_id| {
                if(terminal_nullability[symbol_id] == .No) {
                    terminal_nullability[production.terminal_id] = .No;
                    production.nullable = .No;
                    changed = true;
                    early_exit = true;
                    break;
                }
                else if(terminal_nullability[symbol_id] == .Maybe) {
                    early_exit = true;
                    break;
                }
            }
            // Production is indeed nullable through all its symbols
            if(!early_exit) {
                terminal_nullability[production.terminal_id] = .Yes;
                production.nullable = .Yes;
                changed = true;
            }
        }
        // No further progress can be made, i.e. solution is stable
        if(!changed) {
            // Maybe must now be converted to No
            pit.reset();
            while(pit.next()) |production| {
                if(production.nullable == .Maybe) {
                    production.nullable = .No;
                }
            }
            // Nullability pass is complete
            break;
        }
    }
}
