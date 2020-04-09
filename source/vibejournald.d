module vibejournald;

import vibe.core.log;

extern(C) int sd_journal_send(const char *format, ...);

class JournaldLogger : Logger {
	import std.format : format;
	import std.string : toStringz;

	LogLine ll;
	string line;
	const(char)* msg;
	const(char)* codeFile;
	const(char)* codeLine;
	const(char)* codeFunc;
	const(char)* priority;

	this() {
		this.msg = "MESSAGE=%s".toStringz();
		this.codeFile = "CODE_FILE=%s".toStringz();
		this.codeLine = "CODE_LINE=%d".toStringz();
		this.codeFunc = "CODE_FUNC=%s".toStringz();
		this.priority = "PRIORITY=%d".toStringz();
	}

	override void beginLine(ref LogLine ll) @safe {
		this.ll = ll;
		this.line = "";
	}

	override void put(scope const(char)[] text) @safe {
		this.line ~= text;
	}

	private int priorityValue() @safe {
		final switch(this.ll.level) {
			case LogLevel.critical:
				return 2;
			case LogLevel.debug_:
				return 7;
			case LogLevel.debugV:
				return 7;
			case LogLevel.diagnostic:
				return 5;
			case LogLevel.error:
				return 3;
			case LogLevel.fatal:
				return 0;
			case LogLevel.info:
				return 6;
			case LogLevel.none:
				return 7;
			case LogLevel.trace:
				return 7;
			case LogLevel.warn:
				return 4;
		}
	}

	override void endLine() {
		() @trusted {
			sd_journal_send(
					this.msg, this.line.toStringz(),
					this.priority, this.priorityValue(),
					this.codeFile, this.ll.file.toStringz(),
					this.codeLine, this.ll.line,
					this.codeFunc, this.ll.func.toStringz(),
					null);
		}();
	}
}

unittest {
	auto jl = cast(shared Logger)new JournaldLogger();
	registerLogger(jl);
	logTrace("Trace");
	logDebug("Debug");
	logInfo("Info");
	logError("Error");
	logWarn("Warning");
	logCritical("Critical");
	logFatal("Fatal");
}
