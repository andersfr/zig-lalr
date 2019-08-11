const std = @import("std");
const warn = std.debug.warn;

usingnamespace @import("json.zig");

const allocator = std.heap.c_allocator;
const memmove = std.mem.copy; // This is implemented as memmove so it is safe (for now)

fn processJsonRpc(jsonrpc: Json) anyerror!void {
    const root = jsonrpc.root.fields;

    // Verify version
    const version = root.find("jsonrpc") orelse return error.NoVersion;
    const version_value = version.value.cast(Variant.StringLiteral) orelse return error.NoVersion;

    if(std.mem.compare(u8, "2.0", version_value.value) != .Equal)
        return error.WrongVersion;

    // Get method
    const method = root.find("method") orelse return error.NoRpcMethod;
    const method_value = method.value.cast(Variant.StringLiteral) orelse return error.NoRpcMethod;

    // Get ID
    const id: isize = blk: {
        const field = root.find("id") orelse break :blk isize(0);
        const field_value = field.value.cast(Variant.IntegerLiteral) orelse return error.BadId;
        break :blk field_value.value;
    };

    // Get params
    const params: ?*Variant.Object = blk: {
        const field = root.find("params") orelse break :blk null;
        const field_value = field.value.cast(Variant.Object) orelse return error.BadParams;
        break :blk field_value;
    };

    // Process some methods
    if(std.mem.compare(u8, "textDocument/didOpen", method_value.value) == .Equal) {
        // textDocument: TextDocumentItem{ uri: string, languageId: string, version: number, text: string }
    }
    else if(std.mem.compare(u8, "textDocument/didChange", method_value.value) == .Equal) {
        // textDocument: VersionedTextDocumentIdentifier{ uri: string, version: number|null }
        // contentChanges[ { range?: { start: Position{ line: number, character:number }, end: Position{} }, rangeLength?: number, text: string } ]
    }
    else if(std.mem.compare(u8, "textDocument/didSave", method_value.value) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
        // text?: string
    }
    else if(std.mem.compare(u8, "textDocument/didClose", method_value.value) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
    }
    else if(std.mem.compare(u8, "textDocument/completion", method_value.value) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
        // position: Position{ line: number, character:number }
        // context?: CompletionContext { not very important }
    }
    else if(std.mem.compare(u8, "textDocument/willSave", method_value.value) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
        // reason: number (Manual=1, AfterDelay=2, FocusOut=3)
    }
    else if(std.mem.compare(u8, "textDocument/willSaveWaitUntil", method_value.value) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
        // reason: number (Manual=1, AfterDelay=2, FocusOut=3)
    }
    else if(std.mem.compare(u8, "initialize", method_value.value) == .Equal) {
        // processId: number|null
        // rootPath?: string|null (deprecated)
        // rootUri: DocumentUri{} | null
        // initializeOptions?: any
        // capabilities: ClientCapabilities{ ... }
        // trace: 'off'|'messages'|'verbose' (defaults to off)
        // workspaceFolders: WorkspaceFolder[]|null
    }
    else if(std.mem.compare(u8, "initialized", method_value.value) == .Equal) {
        // params: empty
    }
    else if(std.mem.compare(u8, "shutdown", method_value.value) == .Equal) {
        // params: void
    }

    // Do something useful
    warn("{} {}\n", id, method_value.value);
}

pub fn main() !void {
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    try buffer.resize(4096);

    const stdin = try std.io.getStdIn();

    var bytes_read: usize = 0;
    var offset: usize = 0;
    stdin_poll: while(true) {
        if(offset >= 18 and std.mem.compare(u8, "Content-Length: ", buffer.items[0..16]) == .Equal) {
            var body_len: usize = 0;
            var index: usize = 16;
            while(index < offset-3) : (index += 1) {
                const c = buffer.items[index];
                if(c >= '0' and c <= '9')
                    body_len = body_len*10 + (c-'0');
                if(c == '\r' and buffer.items[index+1] == '\n') {
                    index += 4;
                    break;
                }
            }
            if(index >= offset)
                continue :stdin_poll;

            body_poll: while(offset < body_len+index) {
                bytes_read = stdin.read(buffer.items[offset..body_len+index]) catch break :stdin_poll;
                if(bytes_read == 0) break;

                offset += bytes_read;

                if(offset == buffer.len)
                    try buffer.resize(buffer.len*2);
            }
            var json = (try Json.initWithString(allocator, buffer.items[index..index+body_len])) orelse return;
            defer json.deinit();

            try processJsonRpc(json);
            index += body_len;
            if(index < offset) {
                memmove(u8, buffer.items, buffer.items[index..offset]);
                offset -= index;
                continue :stdin_poll;
            }
            offset = 0;
        }

        bytes_read = stdin.read(buffer.items[offset..]) catch break;
        if(bytes_read == 0) break;

        offset += bytes_read;

        if(offset == buffer.len)
            try buffer.resize(buffer.len*2);

    }
}

