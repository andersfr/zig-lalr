const std = @import("std");
const warn = std.debug.warn;

const ZigParser = @import("zig_parser.zig").Parser;
const ZigNode = @import("zig_parser.zig").Node;

usingnamespace @import("json.zig");

const allocator = std.heap.c_allocator;
const memmove = std.mem.copy; // This is implemented as memmove so it is safe (for now)

var stdout_file: std.fs.File = undefined;
var stdout: std.fs.File.OutStream = undefined;
var debug: std.fs.File.OutStream = undefined;

const initialize_response =
    \\{"id":1,"jsonrpc":"2.0","result":{"capabilities":{"signatureHelpProvider":{"triggerCharacters":["(",","]},"textDocumentSync":1,"completionProvider":{"resolveProvider":false,"triggerCharacters":[".",":"]},"documentHighlightProvider":false,"codeActionProvider":false,"workspace":{"workspaceFolders":{"supported":true}}}}}
    ;
const error_response =
    \\"jsonrpc":"2.0","error":{"code":-32002,"message":"NotImplemented"}}
    ;

fn processSource(uri: []const u8, version: usize, source: []const u8) !void {
    var parser = try ZigParser.init(std.heap.c_allocator);
    defer parser.deinit();

    if(try parser.run(source)) {
        // try debug.stream.print("parsed {} v.{}\n", uri, version);
        var eit = parser.engine.errors.iterator(0);
        var buffer = try std.Buffer.initSize(std.heap.c_allocator, 0);
        defer buffer.deinit();

        var stream = &std.io.BufferOutStream.init(&buffer).stream;
        try stream.write(
            \\{"jsonrpc":"2.0","method":"textDocument/publishDiagnostics","params":{"uri":
        );
        try stream.print("\"{}\",\"diagnostics\":[", uri);

        // Diagnostic: { range, severity?: number, code?: number|string, source?: string, message: string, relatedInformation?: ... }
        while(eit.next()) |err| {
            try stream.write(
                \\{"range":{"start":{
            );
            try stream.print("\"line\":{},\"character\":{}", err.line-1, err.start-1);
            try stream.write(
                \\},"end":{
            );
            try stream.print("\"line\":{},\"character\":{}", err.line-1, err.end);
            try stream.write(
                \\}},"severity":1,"source":"zig-lsp","message":
            );
            try stream.print("\"{}\",\"code\":\"{}\"", @tagName(err.info), @enumToInt(err.info));
            try stream.write(
                \\,"relatedInformation":[]},
            );
            // try debug.stream.print("{}\n", err);
        }
        buffer.list.len -= 1;

        try stream.write(
            \\]}}
        );

        try stdout.stream.print("Content-Length: {}\r\n\r\n", buffer.len());
        try stdout.stream.write(buffer.toSlice());

        // try debug.stream.print("Content-Length: {}\r\n\r\n", buffer.len());
        // try debug.stream.write(buffer.toSlice());
    }
}

fn processJsonRpc(jsonrpc: Json) !bool {
    const root = jsonrpc.root;

    // Verify version
    const rpc_version = root.v("jsonrpc").s("").?;

    if(std.mem.compare(u8, "2.0", rpc_version) != .Equal)
        return error.WrongVersion;

    // Get method
    const rpc_method = root.v("method").s("").?;

    // Get ID
    const rpc_id = root.v("id").u(0).?;

    // Get Params
    const rpc_params = root.v("params");

    try debug.stream.print("rpc: id={}, method={}\n", rpc_id, rpc_method);

    // Process some methods
    if(std.mem.compare(u8, "textDocument/didOpen", rpc_method) == .Equal) {
        // textDocument: TextDocumentItem{ uri: string, languageId: string, version: number, text: string }
        const document = rpc_params.v("textDocument");
        const uri = document.v("uri").s("").?;
        const lang = document.v("languageId").s("").?;
        const version = document.v("version").u(0).?;
        const text = document.v("text").s("").?;

        try processSource(uri, version, text);
    }
    else if(std.mem.compare(u8, "textDocument/didChange", rpc_method) == .Equal) {
        // textDocument: VersionedTextDocumentIdentifier{ uri: string, version: number|null }
        // contentChanges[ { range?: { start: Position{ line: number, character:number }, end: Position{} }, rangeLength?: number, text: string } ]
        const document = rpc_params.v("textDocument");
        const uri = document.v("uri").s("").?;
        const version = document.v("version").u(0).?;

        const change = rpc_params.v("contentChanges").at(0);
        const text = change.v("text").s("").?;

        try processSource(uri, version, text);
    }
    else if(std.mem.compare(u8, "textDocument/didSave", rpc_method) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
        // text?: string
        const uri = rpc_params.v("textDocument").v("uri").s("").?;
        const text = rpc_params.v("text").s("").?;

        // try processSource(uri, 0, text);
    }
    else if(std.mem.compare(u8, "textDocument/didClose", rpc_method) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
        const uri = rpc_params.v("textDocument").v("uri").s("").?;
    }
    else if(std.mem.compare(u8, "textDocument/completion", rpc_method) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
        // position: Position{ line: number, character:number }
        // context?: CompletionContext { not very important }
        const uri = rpc_params.v("textDocument").v("uri").s("").?;
        const position = rpc_params.v("position");
        const iline = position.v("line").i(-1).?;
        const icharacter = position.v("character").i(-1).?;

        if(uri.len > 0 and iline >= 0 and icharacter >= 0) {
            const line = @bitCast(u64, iline);
            const character = @bitCast(u64, icharacter);
            try debug.stream.print("completion [{}] {}:{}\n", uri, line+1, character+1);
        }
    }
    else if(std.mem.compare(u8, "textDocument/willSave", rpc_method) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
        // reason: number (Manual=1, AfterDelay=2, FocusOut=3)
    }
    else if(std.mem.compare(u8, "textDocument/willSaveWaitUntil", rpc_method) == .Equal) {
        // textDocument: TextDocumentIdentifier{ uri: string }
        // reason: number (Manual=1, AfterDelay=2, FocusOut=3)
    }
    else if(std.mem.compare(u8, "initialize", rpc_method) == .Equal) {
        // processId: number|null
        // rootPath?: string|null (deprecated)
        // rootUri: DocumentUri{} | null
        // initializeOptions?: any
        // capabilities: ClientCapabilities{ ... }
        // trace: 'off'|'messages'|'verbose' (defaults to off)
        // workspaceFolders: WorkspaceFolder[]|null
        try stdout.stream.print("Content-Length: {}\r\n\r\n", initialize_response.len);
        try stdout.stream.write(initialize_response);
        return true;
    }
    else if(std.mem.compare(u8, "initialized", rpc_method) == .Equal) {
        // params: empty
    }
    else if(std.mem.compare(u8, "shutdown", rpc_method) == .Equal) {
        // params: void
        return false;
    }
    else if(std.mem.compare(u8, "$/cancelRequest", rpc_method) == .Equal) {
        // id: number|string
    }
    // Only requests need a response
    if(rpc_id > 0) {
        var digits: usize = 0;
        while(digits*10 < rpc_id) : (digits += 1) {}
        try stdout.stream.print("Content-Length: {}\r\n\r\n{}\"id\":{}", error_response.len+digits+6, "{", rpc_id);
        try stdout.stream.write(error_response);
    }
    return true;
}

pub fn main() !void {
    var file = try std.fs.File.openWrite("/Users/andersfr/Repos/zig-lalr/lsp-debug.txt");
    defer file.close();

    debug = file.outStream();

    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    try buffer.resize(4096);

    const stdin = try std.io.getStdIn();
    stdout_file = try std.io.getStdOut();
    stdout = stdout_file.outStream();

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
            // try debug.stream.write("-->\n");
            // try debug.stream.write(buffer.items[0..index+body_len]);
            // try debug.stream.write("\n");
            var json = (try Json.initWithString(allocator, buffer.items[index..index+body_len])) orelse return;
            defer json.deinit();

            if(!(try processJsonRpc(json)))
                break :stdin_poll;

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

