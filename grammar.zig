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

    pub fn debug(self: Self, grammar: *const Grammar) void {
        warn("{} ", varToStr(self.nullable));
        self.debugWithDot(grammar, ~@intCast(usize, 0));
    }

    pub fn debugWithDot(self: Self, grammar: *const Grammar, dot: usize) void {
        if(grammar.isSpecial(self.terminal_id)) {
            warn("\x1b[35m{}\x1b[0m[{}] <-", self.terminal, self.terminal_id);
        }
        else {
            warn("\x1b[34m{}\x1b[0m[{}] <-", self.terminal, self.terminal_id);
        }
        for(self.symbol_ids) |id,i| {
            if(i == dot) {
                warn(" .");
            }
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
        if(self.symbol_ids.len == dot) {
            warn(" .");
        }
        warn("\n");
    }
};

pub const Grammar = struct {
    allocator: *std.mem.Allocator,
    productions: ArrayList(*Production),
    names_index_map: StringIndexMap(usize),
    epsilon_index: usize = 0,
    grammar_name: []const u8,

    const Self = @This();

    pub fn init(allocator: *std.mem.Allocator, name: []const u8) Self {
        return Self{ 
            .allocator = allocator, 
            .productions = ArrayList(*Production).init(allocator),
            .names_index_map = StringIndexMap(usize).init(allocator),
            .grammar_name = name,
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

        debug(self);

        // Build the isocore set
        try isocorePass(self);
    }

    pub fn terminalCount(self: Self) usize {
        return self.epsilon_index;
    }

    pub fn debug(self: *const Self) void {
        warn("{}\n", self.grammar_name);
        var it = self.productions.iterator();
        while(it.next()) |production| {
            production.debug(self);
        }
        warn("\n");
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
        return self.names_index_map.keyOf(index)[0] == '$';
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

const IsocorePair = struct {
    production_id: u32,
    symbol_index: u32,

    const Self = @This();

    pub fn init(production_id: u32, symbol_index: u32) Self {
        return Self{ .production_id = production_id, .symbol_index = symbol_index };
    }

    pub fn hash(self: Self) u32 {
        const upper = @intCast(u64, self.production_id) << 32;
        const lower = @intCast(u64, self.symbol_index);

        return std.hash.Murmur3_32.hashUint64(upper | lower);
    }

    pub fn equal(p1: Self, p2: Self) bool {
        return p1.production_id == p2.production_id and p1.symbol_index == p2.symbol_index;
    }
};

const IsocorePairSet = FlatHash.Set(IsocorePair, null, IsocorePair.hash, IsocorePair.equal);

fn isocorePass(grammar: *Grammar) !void {
    // Isocores holds all the states that are being built
    var isocores = ArrayList(IsocorePairSet).init(grammar.allocator);
    // Cleanup of self and its containing items
    defer {
        var it = isocores.iterator();
        while(it.next()) |*isocore| {
            isocore.deinit();
        }
        isocores.deinit();
    }

    // Transitions holds the shift and goto transitions between isocore states
    var transitions = ArrayList([]u32).init(grammar.allocator);
    // Cleanup of self and its containing items
    defer {
        var it = transitions.iterator();
        while(it.next()) |transition| {
            grammar.allocator.free(transition);
        }
        transitions.deinit();
    }

    // Initialize in own block for correct errdefer scoping
    {
        // Initialize the accepting isocore set
        var accept_set = IsocorePairSet.init(grammar.allocator);
        errdefer accept_set.deinit();

        // Insert $accept <- . `initial` $eof
        _ = try accept_set.insert(IsocorePair.init(0, 0));

        // Append to the isocores set
        _ = try isocores.append(accept_set);
    }

    // Initialize transitions for initial isocore
    {
        // Allocate room for all terminals and non-terminals
        const slice = try grammar.allocator.alloc(u32, grammar.names_index_map.size());
        errdefer grammar.allocator.free(slice);

        // It is impossible to transition into the initial isocore state
        std.mem.set(u32, slice, 0);

        // Append it to the transitions list
        try transitions.append(slice);
    }

    // The isocores are expanded during processing - allocate once for efficiency
    var expansion_core = IsocorePairSet.init(grammar.allocator);
    defer expansion_core.deinit();

    // Temporary set for building transitions
    var transition_core = IsocorePairSet.init(grammar.allocator);
    defer transition_core.deinit();

    // Process the isocores sequentially as they are built
    // Note: uses indexing to avoid iterator invalidation
    var current_isocore: usize = 0;
    while(current_isocore < isocores.len) : (current_isocore += 1) {
        // Reset the expansion and copy the current isocore
        expansion_core.reset();
        {
            // Isocore pair copying
            var pit = isocores.at(current_isocore).iterator();
            while(pit.next()) |kv| {
                _ = try expansion_core.insert(kv.key);
            }
        }

        // Expand until convergence (note: this can be optimized with a queue)
        while(true) {
            var changed: bool = false;
            // Try to expand every production in the core
            var pit = expansion_core.iterator();
            while(pit.next()) |kv| {
                const pair = kv.key;
                const production = grammar.productions.at(pair.production_id);
                // Check that it is within bounds (dot can follow last symbol)
                if(pair.symbol_index < production.symbol_ids.len) {
                    // Check that a terminal is following (non-terminals have no expansion)
                    const symbol_id = production.symbol_ids[pair.symbol_index];
                    if(grammar.isTerminal(symbol_id)) {
                        // Try to insert all productions that can produce this terminal
                        var i: usize = 0;
                        while(i < grammar.productions.len) : (i += 1) {
                            const nested_production = grammar.productions.at(i);
                            if(nested_production.terminal_id == symbol_id) {
                                const result = try expansion_core.insert(IsocorePair.init(@intCast(u32, i), 0));
                                // Record whether or not the core expanded
                                changed = changed or result.is_new;
                            }
                        }
                    }
                }
                // If expanded the iterators may have been invalidated
                if(changed) break;
            }
            // Expansion core has converged
            if(!changed) break;
        }

        // Build transitions for this isocore
        {
            // Visit every expansion and build its transitions
            var pit = expansion_core.iterator();
            outer: while(pit.next()) |kv| {
                const pair = kv.key;
                const production = grammar.productions.at(pair.production_id);
                const transition = transitions.at(current_isocore);

                // Completed productions cannot transition
                if(pair.symbol_index >= production.symbol_ids.len)
                    continue;

                const transition_symbol = production.symbol_ids[pair.symbol_index];

                // Transition already processed or is special, i.e. $accept, $epsilon, $eof
                if(grammar.isSpecial(transition_symbol) or transition[transition_symbol] != 0)
                    continue;

                // Prepare temporary transition core
                transition_core.reset();
                _ = try transition_core.insert(IsocorePair.init(pair.production_id, pair.symbol_index+1));

                var tit = pit;
                while(tit.next()) |tkv| {
                    const tpair = tkv.key;
                    const tproduction = grammar.productions.at(tpair.production_id);

                    // Completed productions cannot transition
                    if(tpair.symbol_index >= tproduction.symbol_ids.len)
                        continue;
    
                    if(tproduction.symbol_ids[tpair.symbol_index] == transition_symbol) {
                        _ = try transition_core.insert(IsocorePair.init(tpair.production_id, tpair.symbol_index+1));
                    }
                }

                // Check if transition core is already in the isocore set
                var iit: usize = 0;
                inner: while(iit < isocores.len) : (iit += 1) {
                    const isocore = isocores.at(iit);
                    // Number of elements must agree to be equal
                    if(isocore.size != transition_core.size)
                        continue :inner;

                    // Check if all keys from isocore is in transition core
                    var it1 = isocore.iterator();
                    while(it1.next()) |kv1| {
                        // If not they cannot be equal
                        if(!transition_core.contains(kv1.key))
                            continue :inner;
                    }

                    // Update transition table
                    transition[transition_symbol] = @intCast(u32, iit);
                    // No new isocore to add so continue in outer loop
                    continue :outer;
                }

                // Initialize in own block for correct errdefer scoping
                {
                    // Initialize the accepting isocore set
                    var new_isocore_set = IsocorePairSet.init(grammar.allocator);
                    errdefer new_isocore_set.deinit();

                    var tcit = transition_core.iterator();
                    while(tcit.next()) |tckv| {
                        _ = try new_isocore_set.insert(tckv.key);
                    }

                    // Update transition table (reference not invalidated yet)
                    transition[transition_symbol] = @intCast(u32, isocores.len);

                    // Append to the isocores set
                    try isocores.append(new_isocore_set);
                }

                // Initialize transitions for new isocore
                {
                    // Allocate room for all terminals and non-terminals
                    const slice = try grammar.allocator.alloc(u32, grammar.names_index_map.size());
                    errdefer grammar.allocator.free(slice);

                    // It is impossible to transition into the initial isocore state
                    std.mem.set(u32, slice, 0);

                    // Append it to the transitions list
                    try transitions.append(slice);
                }
            }
        }

        // Debug
        warn("Isocore {}:\n------------\n", current_isocore);
        {
            var pit = expansion_core.iterator();
            while(pit.next()) |kv| {
                const pair = kv.key;
                grammar.productions.at(pair.production_id).debugWithDot(grammar, pair.symbol_index);
            }
        }
        warn("\n");
    }
}
