module vibejournald;

import vibe.core.log;

extern(C) int sd_journal_send(const char *format, ...);

class JournaldLogger : Logger {
	import std.format : format;
	import std.string : toStringz;

	LogLine ll;
	string line;

	override void beginLine(ref LogLine ll) @safe {
		this.ll = ll;
		this.line = "";
	}

	override void put(scope const(char)[] text) @safe {
		this.line ~= text;
	}

	private const(char)* priorityString() @safe {
		int value;
		final switch(this.ll.level) {
			case LogLevel.critical:
				value = 2;
				break;
			case LogLevel.debug_:
				value = 7;
				break;
			case LogLevel.debugV:
				value = 7;
				break;
			case LogLevel.diagnostic:
				value = 5;
				break;
			case LogLevel.error:
				value = 3;
				break;
			case LogLevel.fatal:
				value = 0;
				break;
			case LogLevel.info:
				value = 6;
				break;
			case LogLevel.none:
				value = 7;
				break;
			case LogLevel.trace:
				value = 7;
				break;
			case LogLevel.warn:
				value = 4;
				break;
		}
		return format("PRIORITY=%d", value).toStringz();
	}

	override void endLine() {
		() @trusted {
			sd_journal_send(
					format("MESSAGE=%s", this.line).toStringz(),
					priorityString(),
					format("CODE_FILE=%s", this.ll.file).toStringz,
					format("CODE_LINE=%s", this.ll.line).toStringz,
					format("CODE_FUNC=%s", this.ll.func).toStringz,
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
