import fs from "node:fs";
import path from "node:path";

const root = path.resolve("../..");
const outDir = path.resolve(".");
const commandsDir = path.join(outDir, "commands");
const assetsDir = path.join(outDir, "assets");
const docsDir = path.join(root, "Documentation", "Methods");
const sourceOriginalDir = path.join(root, "Documentation", "Original");
const originalDir = path.join(outDir, "original");
const legacyDir = path.join(outDir, "original-reference");

const publicApi = [
  "LOG ADD ENTRY",
  "LOG ENABLE",
  "LOG CONFIG",
  "LOG CREATE TABLE",
  "LOG DECLARE LOG",
  "LOG USE LOG",
  "LOG FLUSH",
  "LOG CLOSE LOG",
  "LOG STOP LOG WRITER",
  "LOG Level",
  "LOG BUG ALERT",
  "Log Current Label",
  "Log Current Log",
  "Log File Name",
  "Log Folder Path",
  "Log Form Event",
  "Log Maximum Size",
];

const testSuite = [
  "_test_LOG_Suite",
  "_test_LOG_Matrix",
  "_test_LOG_Process",
  "_test_LOG_Verify",
  "_test_LOG_AllDestinations",
  "_test_LOG_Destinations",
  "_test_LOG_RecordStructure",
  "_test_Export",
  "STRESS TEST",
  "_____Testing",
];

const configOptions = [
  ["Logging Folder Path", "folderPath", "Text", "4D Logs folder", "Default folder for future log declarations and for the default process log. Pass a resolved path string, not a 4D folder constant."],
  ["Logging File Suffix", "fileSuffix", "Text", ".txt", "Suffix used when a log is declared with only a label. Use Log File Suffix Text for .txt or Log File Suffix Log for .log. Empty text resets to .txt."],
  ["Logging End Of Line", "eol", "Text", "LF", "Line ending written to future logs. Use Log End Of Line LF, Log End Of Line CR, or Log End Of Line CRLF."],
  ["Logging Use Batch", "useBatch", "Boolean", "True", "Default write policy for future declared logs. True buffers entries in the Log Writer worker; False makes future logs write in real time."],
  ["Logging Report Batch", "reportBatch", "Boolean", "False", "Diagnostic preference stored with future declarations. When enabled, batch writes append a diagnostic row with - in the level column plus cause, entry count, character count, and elapsed milliseconds."],
  ["Logging Flush Interval", "flushInterval", "Number", "9", "Batch interval in seconds. Fractional seconds are accepted. A value of 0 creates real-time behaviour for the affected log."],
  ["Logging Flush Char Limit", "flushCharLimit", "Number", "About 64,000", "Buffered character threshold. The writer flushes before appending an entry that would push the buffer beyond this size."],
  ["Logging Flush Entry Limit", "flushEntryLimit", "Number", "1,000", "Buffered entry-count threshold. The writer flushes when the buffer reaches this many queued entries."],
  ["Logging Rollover Bytes", "rolloverBytes", "Number", "0", "Maximum physical log-file size in bytes. 0 disables rollover. When enabled, the writer archives the existing file and starts a new one after a physical write exceeds the limit."],
  ["Logging Archive Compressed", "archiveCompressed", "Boolean", "True", "Archive compression preference for rollover files. The current writer compresses rollover archives after moving the old file."],
  ["Logging Include Machine Name", "includeMachineName", "Boolean", "False", "When enabled, rendered text rows include Current machine after the timestamp. ServerFile writes the client-rendered line, so this captures the client machine in client/server mode."],
  ["Logging Destinations", "destinations", "Number", "Log to LocalFile", "Default destination bitmask for future declarations. Log to Default resolves to Log to LocalFile."],
  ["sqliteEndpoint", "sqliteEndpoint", "Text", "http://127.0.0.1:8787", "SQLite helper service base URL used by the incomplete SQLite destination."],
  ["sqliteAPIKey", "sqliteAPIKey", "Text", "Empty", "Optional SQLiteLogger X-Log-API-Key value."],
  ["sqliteTimeout", "sqliteTimeout", "Number", "5", "SQLite helper service HTTP timeout in seconds. Values below 1 are normalised to 1."],
];

const destinations = [
  ["Log to Default", "0", "Configuration placeholder. It resolves to the configured default destination, and the configured default resolves to Log to LocalFile."],
  ["Log to LocalFile", "1", "Writes the rendered text row through the local Log Writer worker."],
  ["Log to ServerFile", "2", "Writes the client-rendered text row through the server-side Log Writer worker. Combined LocalFile+ServerFile collapses to one file write outside 4D Remote mode."],
  ["Log to 4D Record", "4", "Writes structured records when the Logging table exists. If the table is missing, the record destination is skipped silently."],
  ["Log to SQLite", "8", "Incomplete. The 4D-side dispatcher and batch sender exist, but the packaged SQLite helper service and install/start/test helpers are not implemented yet."],
  ["Log to Offsite", "16", "Not implemented. The constant is reserved and recognised so it does not fall back to LocalFile by mistake."],
];

const destinationWarning = {
  title: "SQLite and Offsite are not ready for production use",
  body: "The constants are present, but these destinations are not complete runtime features yet. SQLite still needs the packaged helper service and developer/admin install-start-test workflow. Offsite delivery is reserved for later work.",
};

const detail = {
  "LOG ADD ENTRY": {
    title: "Add an entry",
    signature: "LOG ADD ENTRY(Variant1{; Variant2; ...VariantN})",
    summary: "Adds one tab-delimited entry to the resolved log file.",
    params: [
      ["text 1", "Text", "Text to add to the log."],
      ["text 2...text N", "Text", "Additional text columns to add to the same log entry. Each text value is separated by a tab in the physical file."],
      ["logOptions", "Object", "Optional metadata that changes routing, level, or flushing for this entry. Supported keys are logLabel, logLevel, and flushNow."],
      ["logLevel", "Integer", "Priority level for filtering. Use Log Level Default, Log Level Info, Log Level Warn, or Log Level Error."],
      ["flushNow", "Boolean", "True flushes the target log immediately after this entry is queued. False clears an earlier flush override in the same call."],
    ],
    body: [
      "Use this command for normal application logging. Each physical row starts with an automatic timestamp and level column, followed by the text parameters as data columns. Tabs and line endings inside text values are escaped so one logical entry remains one physical line.",
      "The command accepts metadata parameters in any position. Text is written to the log; numbers set the requested log level; objects provide options; booleans set the flush override. If more than one level is supplied, the later level wins. This lets wrapper methods set a default level while still allowing callers to override it.",
      "The level column is written as -, info, warn, or error. Log Level Default, unlevelled entries, and unknown numeric levels write -.",
      "If includeMachineName is enabled through LOG CONFIG or LOG DECLARE LOG, rendered text rows start with timestamp, machine name, level, then caller columns. This applies to LocalFile and ServerFile because ServerFile writes the client-rendered line.",
      "Each dispatched entry also carries structured metadata for destination handlers, including the local timestamp, UTC timestamp, process name, machine name, level, original columns, rendered line, flush policy, report-batch flag, and destination mask.",
      "If the logLabel option is supplied, only this entry is routed to that named log. The process log selection is restored immediately afterwards.",
    ],
    extra: [
      ["Entry options", table(["Option", "Type", "Effect"], [
        ["logLabel", "Text", "Routes this single entry to a declared log label."],
        ["logLevel", "Integer", "Sets the level used for filtering and for the physical level column. A later numeric level parameter overrides this value."],
        ["flushNow", "Boolean", "Flushes the resolved target log immediately after queueing the entry."],
      ])],
      ["Compatibility note", "<p>Older calls that pass only text continue to work. If you need to write a number or boolean as log text, convert it first with <code>String</code>; otherwise the value is treated as metadata.</p>"],
    ],
    examples: [
      ["Basic entry", `LOG ENABLE(True)
LOG ADD ENTRY("Database launched.")
LOG ADD ENTRY(Current method name; "Display record called.")`],
      ["Additional columns", `LOG ADD ENTRY(Current method name; "Import finished"; "Rows"; String($rowCount_i))`],
      ["Options object", `$options_o:=New object("logLabel"; "Audit"; "logLevel"; Log Level Warn)
LOG ADD ENTRY($options_o; "Customer changed"; "Customer"; $customerID_t)`],
    ],
  },
  "LOG ENABLE": {
    title: "Enable or disable routine logging",
    signature: "LOG ENABLE({enable}) -> Boolean",
    summary: "Sets or returns the current process logging state.",
    params: [
      ["enable", "Boolean", "True enables routine logging for the current process. False disables routine logging for the current process."],
      ["Result", "Boolean", "The current process logging state after any requested change."],
    ],
    body: [
      "The enabled state is process local. Calling LOG ENABLE in one process does not directly enable every other process.",
      "In the modern component, disabled logging is a filtering mode rather than a hard stop. When logging is disabled, LOG ADD ENTRY still writes entries whose requested level is at or above the effective log level. Set LOG Level to Warn or Error when you want disabled logging to suppress ordinary entries while still allowing important entries through.",
    ],
    examples: [
      ["Turn logging on", `$wasEnabled_b:=LOG ENABLE(True)
LOG ADD ENTRY("Database launched.")`],
      ["Use disabled mode for warnings and errors only", `LOG ENABLE(False)
$currentLevel_i:=LOG Level(Log Level Warn)
LOG ADD ENTRY(Log Level Info; "Not written")
LOG ADD ENTRY(Log Level Error; "Written")`],
    ],
  },
  "LOG CONFIG": {
    title: "Configure application-wide defaults",
    signature: "LOG CONFIG({Options}) -> Object",
    summary: "Sets or returns defaults used by future log declarations.",
    params: [
      ["Options", "Object", "Optional configuration object. Only recognised properties with the expected value type are applied."],
      ["Result", "Object", "The effective application-wide configuration after any update."],
    ],
    body: [
      "Call this during startup before LOG DECLARE LOG when you want to change the component defaults. Existing declared logs are not rewritten. Explicit values passed to LOG DECLARE LOG still win over the configured defaults.",
      "LOG CONFIG also refreshes the default process log if the current process is still using the undeclared default log.",
      "Destination defaults are a bitmask. Use Log to LocalFile for normal file logging, add Log to ServerFile for server-side file writes in client/server deployments, and add Log to 4D Record when the Logging table should receive structured records.",
      "SQLite and offsite destination values are present for forward compatibility. SQLite configuration keys can be stored now, but the SQLite helper service is not packaged yet. Offsite delivery remains reserved for future implementation.",
    ],
    extra: [
      ["Implementation warning", warningBanner(destinationWarning.title, destinationWarning.body)],
      ["Configuration options", table(["Constant", "Object key", "Type", "Default", "Explanation"], configOptions)],
      ["Destination values", table(["Constant", "Value", "Effect"], destinations)],
      ["Configuration example", { code: `$config_o:=LOG CONFIG(New object( \\
	Logging Folder Path; $logsFolder_t; \\
	Logging File Suffix; Log File Suffix Log; \\
	Logging End Of Line; Log End Of Line CRLF; \\
	Logging Use Batch; True; \\
	Logging Flush Interval; 0.5; \\
	Logging Flush Entry Limit; 250; \\
	Logging Rollover Bytes; 10485760; \\
	Logging Include Machine Name; True; \\
	Logging Destinations; Log to LocalFile+Log to 4D Record; \\
	"sqliteEndpoint"; "http://127.0.0.1:8787"; \\
	"sqliteTimeout"; 5))` }],
    ],
    examples: [
      ["Read current defaults", `$config_o:=LOG CONFIG
LOG ADD ENTRY("Configured folder"; $config_o[Logging Folder Path])`],
      ["Change defaults for future declarations", `$config_o:=LOG CONFIG(New object(Logging File Suffix; Log File Suffix Log))
LOG DECLARE LOG("Audit")  // Uses Audit.log`],
    ],
  },
  "LOG CREATE TABLE": {
    title: "Create the record destination table",
    signature: "LOG CREATE TABLE -> Object",
    summary: "Creates the Logging table and indexes if they are missing.",
    params: [
      ["Result", "Object", "Structure creation result from the table/index setup routine."],
    ],
    body: [
      "Use this helper when an application wants to enable the Log to 4D Record destination. It creates the Logging table and indexes idempotently when they are missing.",
      "When the table is newly created, the method alerts the developer to restart or reopen the database before sending entries to the 4D Record destination. This restart is required before ORDA writes can see the newly-created structure.",
      "If the table cannot be created, the returned object carries the details and an alert asks the developer to inspect that result.",
    ],
    examples: [
      ["Create or verify the table", `$result_o:=LOG CREATE TABLE
If ($result_o.success)
	LOG CONFIG(New object(Logging Destinations; Log to LocalFile+Log to 4D Record))
End if`],
    ],
  },
  "LOG DECLARE LOG": {
    title: "Declare a named log",
    signature: "LOG DECLARE LOG(Label{; File Name{; Folder Path{; Policy/Options}}})",
    summary: "Registers a log label with a physical file name, folder, write policy, and destination policy.",
    params: [
      ["Label", "Text", "The name used by application code to select or route to this log."],
      ["File Name", "Text", "Optional physical file name. If omitted, the label plus the configured file suffix is used."],
      ["Folder Path", "Text", "Optional folder path. If omitted, the configured folder path is used."],
      ["Policy/Options", "Variant", "Optional write policy. Pass Log Flush Real Time or 0 for real-time writes, Log Flush Default for configured batching, a number of seconds for a batching interval, or an object with Logging Flush Interval, Logging Destinations, and Logging Include Machine Name."],
    ],
    body: [
      "A label is not the same thing as a file name. The label is the stable name used by code; the file name and folder describe where the log is written.",
      "A one-parameter declaration preserves an existing declaration. Passing file name, folder, flush policy, or an options object updates the stored declaration for that label.",
      "Use an options object when a log needs a destination mask or a per-log machine-name setting. Log to Default resolves through LOG CONFIG; if the configured default is also Log to Default, the component falls back to Log to LocalFile.",
    ],
    extra: [
      ["Implementation warning", warningBanner(destinationWarning.title, destinationWarning.body)],
      ["Destination values", table(["Constant", "Value", "Effect"], destinations)],
    ],
    examples: [
      ["Default file and folder", `LOG DECLARE LOG("Audit")  // Audit.txt in the configured log folder`],
      ["Explicit location", `LOG DECLARE LOG("Audit"; "Audit Log.txt"; $folderPath_t)`],
      ["Real-time and batched logs", `LOG DECLARE LOG("Errors"; "Errors.txt"; $folderPath_t; Log Flush Real Time)
LOG DECLARE LOG("Import"; "Import.txt"; $folderPath_t; 10)`],
      ["Structured record destination", `$options_o:=New object( \\
	Logging Destinations; Log to LocalFile+Log to 4D Record; \\
	Logging Flush Interval; Log Flush Default; \\
	Logging Include Machine Name; True)
LOG DECLARE LOG("Audit"; "Audit.txt"; $folderPath_t; $options_o)`],
    ],
  },
  "LOG USE LOG": {
    title: "Select the current process log",
    signature: "LOG USE LOG({Log Label})",
    summary: "Switches the current process to a named log, or back to the default log.",
    params: [
      ["Log Label", "Text", "Optional log label. Omit it, or pass empty text, to return to the default log."],
    ],
    body: [
      "Use this when a process should write a series of entries to a named log. For a single routed entry, prefer the logLabel option on LOG ADD ENTRY so the process selection does not change.",
      "If the label has not already been declared, the method declares it using the current defaults.",
    ],
    examples: [["Switch and restore", `LOG DECLARE LOG("Audit"; "Audit.txt")
LOG USE LOG("Audit")
LOG ADD ENTRY("Written to Audit")
LOG USE LOG
LOG ADD ENTRY("Written to the default log")`]],
  },
  "LOG FLUSH": {
    title: "Flush buffered entries",
    signature: "LOG FLUSH({Log Label})",
    summary: "Forces buffered log entries to be physically written.",
    params: [
      ["Log Label", "Text", "Optional log label. If omitted, all buffered logs are flushed."],
    ],
    body: [
      "Normal batched writes are durable only after a flush occurs. Use LOG FLUSH before a risky operation, before reading a generated log file, or before handing control back to code that expects the physical file to be current.",
      "Flushing a label affects the physical log file behind that label. Calling without a label flushes every buffered log known to the writer.",
    ],
    examples: [["Manual durability point", `LOG ADD ENTRY(New object("logLabel"; "Audit"); "Before export")
LOG FLUSH("Audit")`]],
  },
  "LOG CLOSE LOG": {
    title: "Close log files",
    signature: "LOG CLOSE LOG({Log Label})",
    summary: "Flushes and closes one named log, or all open logs.",
    params: [
      ["Log Label", "Text", "Optional log label. If omitted, all logs are flushed and closed."],
    ],
    body: [
      "Use this when a log file must be complete and closed before another process reads, moves, or archives it. Closing all logs clears the writer's open document references and buffers.",
    ],
    examples: [["Close all logs", `LOG FLUSH
LOG CLOSE LOG`]],
  },
  "LOG STOP LOG WRITER": {
    title: "Stop the Log Writer worker",
    signature: "LOG STOP LOG WRITER",
    summary: "Flushes outstanding work and stops the writer worker.",
    params: [],
    body: [
      "The writer is restarted automatically when needed. Use this at controlled shutdown points or tests where the next step needs all queued data written and no writer state left open.",
    ],
    examples: [["Shutdown sequence", `LOG FLUSH
LOG STOP LOG WRITER`]],
  },
  "LOG Level": {
    title: "Set the log threshold",
    signature: "LOG Level(newLogLevel{; global}) -> Integer",
    summary: "Sets the process or global log level threshold.",
    params: [
      ["newLogLevel", "Integer", "One of Log Level Default, Log Level Info, Log Level Warn, or Log Level Error."],
      ["global", "Boolean", "Optional. When supplied, the shared global threshold is set instead of the current process threshold."],
      ["Result", "Integer", "The current process log level."],
    ],
    body: [
      "The effective threshold is the greater of the current process level and the shared global level. When LOG ENABLE(False) is in effect, LOG ADD ENTRY writes only entries whose requested level is at or above that effective threshold.",
      "Use the named constants rather than hard-coded numbers. Their relative severity is Default, Info, Warn, Error.",
      "Unknown numeric threshold values are ignored; the current threshold is left unchanged.",
    ],
    examples: [["Process and global thresholds", `$processLevel_i:=LOG Level(Log Level Info)
$processLevel_i:=LOG Level(Log Level Error; True)
LOG ENABLE(False)
LOG ADD ENTRY(Log Level Warn; "Suppressed")
LOG ADD ENTRY(Log Level Error; "Written")`]],
  },
  "LOG BUG ALERT": {
    title: "Report an unexpected code path",
    signature: "LOG BUG ALERT(Bug Details{; More Details{; Line number{; Display Alert}}})",
    summary: "Reports an unexpected internal condition to the 4D logs and, optionally, displays an alert.",
    params: [
      ["Bug Details", "Variant", "Either the method name as text or an object containing methodName, errorDetails, lineNumber, and displayAlert."],
      ["More Details", "Text", "Optional error description when using positional parameters."],
      ["Line number", "Longint", "Optional line number."],
      ["Display Alert", "Boolean", "Optional alert flag. Defaults to True in common calling forms."],
    ],
    body: [
      "This is a developer diagnostic helper, not the normal application logging entry point. It writes to the 4D command and debug logs, can raise an alert in the application process, and currently drops into TRACE.",
      "Use LOG ADD ENTRY for operational log records. Use LOG BUG ALERT when a missing parameter or unexpected path indicates a programming error.",
    ],
    examples: [["Object form", `$error_o:=New object("methodName"; Current method name; \\
	"errorDetails"; "Missing required parameter"; \\
	"lineNumber"; 42; \\
	"displayAlert"; True)
LOG BUG ALERT($error_o)`]],
  },
  "Log Current Label": {
    title: "Read the current log label",
    signature: "Log Current Label -> Text",
    summary: "Returns the active process log label.",
    params: [["Result", "Text", "The current label, or empty text when the process is using the default log or a direct file/folder selection."]],
    body: ["Use this when you need to report or restore the selected label. It returns a label, not a file name."],
    examples: [["Log the current label", `$label_t:=Log Current Label
LOG ADD ENTRY("Current label"; $label_t)`]],
  },
  "Log Current Log": {
    title: "Read the current log file name",
    signature: "Log Current Log -> Text",
    summary: "Returns the current process log file name.",
    params: [["Result", "Text", "The current physical log file name."]],
    body: ["This reports the file name resolved for the current process. It does not return the label."],
    examples: [["Report the active file", `$file_t:=Log Current Log
LOG ADD ENTRY("Current log file"; $file_t)`]],
  },
  "Log File Name": {
    title: "Set or read the current file name",
    signature: "Log File Name({Log File Name}) -> Text",
    summary: "Sets or returns the current process log file name directly.",
    params: [
      ["Log File Name", "Text", "Optional physical file name."],
      ["Result", "Text", "The current physical file name."],
    ],
    body: ["Setting a file name directly clears the current label. Prefer LOG DECLARE LOG and LOG USE LOG for named logs; use this helper when you deliberately want to target a specific file name."],
    examples: [["Direct file selection", `$file_t:=Log File Name("Import.txt")
LOG ADD ENTRY("Import log selected"; $file_t)`]],
  },
  "Log Folder Path": {
    title: "Set or read the current folder",
    signature: "Log Folder Path({Folder Path}) -> Text",
    summary: "Sets or returns the current process log folder directly.",
    params: [
      ["Folder Path", "Text", "Optional resolved folder path."],
      ["Result", "Text", "The current process log folder path."],
    ],
    body: ["Setting a folder directly clears the current label. Prefer LOG CONFIG for application-wide defaults or LOG DECLARE LOG for named log locations."],
    examples: [["Direct folder selection", `$folder_t:=Log Folder Path($logsFolder_t)
LOG ADD ENTRY("Log folder"; $folder_t)`]],
  },
  "Log Form Event": {
    title: "Describe the current form event",
    signature: "Log Form Event -> Text",
    summary: "Returns text describing the current form event.",
    params: [["Result", "Text", "The current form event description."]],
    body: ["This is useful when instrumenting form methods and wanting readable event names in the log rather than raw event codes."],
    examples: [["Log a form event", `$event_t:=Log Form Event
LOG ADD ENTRY(Current method name; "Form event"; $event_t)`]],
  },
  "Log Maximum Size": {
    title: "Set or read rollover size",
    signature: "Log Maximum Size({Maximum size}) -> Longint",
    summary: "Sets or returns the maximum physical log size before rollover.",
    params: [
      ["Maximum size", "Longint", "Optional maximum size in bytes. Pass 0 to disable rollover."],
      ["Result", "Longint", "The active maximum size in bytes."],
    ],
    body: ["When rollover is enabled and a physical write pushes a file beyond the limit, the writer closes and moves the existing file to a timestamped archive name, creates a fresh log file, and compresses the archive."],
    examples: [["Set 10 MB rollover", `$maxBytes_i:=Log Maximum Size(10485760)`], ["Disable rollover", `$maxBytes_i:=Log Maximum Size(0)`]],
  },
};

const permission = {
  title: "[ANN] Free Foundation 4 Logging Component Released",
  date: "8 January 2005 at 02:51",
  from: "Dave Batton <Dave@foundationshell.com>",
  replyTo: "4D iNUG Technical <4D_Tech@lists.4dinug.org>",
  to: "4D iNUG Technical <4D_Tech@lists.4dinug.org>",
  body: [
    "4D Developers,",
    "If you're interested in giving components a try, download the free Foundation Logging component. This component, along with the full source code, is being released at no charge to introduce 4D developers to 4D's powerful component system.",
    "The Foundation Logging component is a stand-alone component (no other Foundation components are required) that logs text messages to an external, tab-delimited text file. It can be a tremendous help when trying to track down intermittent problems in a compiled database. The component can easily be installed into any 4D 2003 or 4D 2004 database.",
  ],
  links: [
    "http://www.FoundationShell.com/components.php#Fnd_Log",
    "http://www.FoundationShell.com/components.php#Fnd_Pswd",
    "http://www.FoundationShell.com/newsletter.php",
    "http://www.FoundationShell.com/",
  ],
  signature: "Dave Batton",
};

const originalDocs = [
  {
    title: "Foundation 4 Logging Component Developer Reference Manual",
    file: "Original Logging Component.pdf",
    description: "Dave Batton's original developer reference for the Foundation Logging component.",
  },
  {
    title: "Free Foundation 4 Logging Component Released",
    file: "[ANN] Free Foundation 4 Logging Component Released.pdf",
    description: "The 2005 public release announcement, including the free source-code notice.",
  },
];

const legacyReference = [
  {
    name: "Foundation Logging Component",
    title: "Foundation Logging Component (Fnd_Log)",
    signature: "Foundation Logging Component Developer Reference Manual, First Edition",
    summary: "Original overview of the Foundation 4 logging component.",
    source: "Original Logging Component.pdf",
    body: [
      "The Foundation Logging component is an optional Foundation component that provides a simple method for logging events to an external text file.",
      "The Fnd_Log component was provided at no cost to both Foundation 4 developers and 4D developers that did not use Foundation. The source code was included in the Foundation Construction Set and in a separate database for non-Foundation developers.",
      "This component simply appends text to an external text file. This can be handy when trying to diagnose database problems, especially those that result in the 4D application crashing.",
      "The current version of this component does not use or interfere with 4D's LOG EVENT command. It does not require any other components, including Fnd_Gen.",
    ],
    extra: [
      ["Default file locations", table(["Platform", "Original location"], [
        ["Windows", "User Preferences folder. The file has the same name as the structure file followed by \" Log.txt\"."],
        ["Mac OS X", "User Logs folder inside Preferences. The file has the same name as the structure file with the .log extension."],
        ["Mac OS 9", "User Preferences folder. The file has the same name as the structure file followed by \" Log\" and file type TEXT."],
      ])],
      ["Sample output", { code: `12/27/2004  19:37:13  On Startup                 Database launched.
12/27/2004  19:37:21  Fnd_aa_IO_DisplayTable     Display table called.
12/27/2004  19:37:26  Fnd_aa_IO_DisplayRecord    Display record called.
12/27/2004  19:37:33  On Exit                    Database quit.` }],
    ],
  },
  {
    name: "Fnd_Log_AddEntry",
    title: "Fnd_Log_AddEntry",
    signature: "Fnd_Log_AddEntry (text 1{; text 2..text N})",
    summary: "Adds text to the original external tab-delimited log file.",
    source: "Original Logging Component.pdf",
    body: [
      "Call this method to add a new entry to the log file. It is safe to call this routine even if logging is not currently enabled.",
      "A single method call is used to add text to the log file. The text is added in a tab-delimited format, along with the current date and time.",
      "If multiple parameters are passed, they are appended to the log entry separated by tabs.",
      "Because this command can accept multiple values, a useful technique is to first pass Current method name, followed by an event description.",
      "No data is actually written to the log file until logging is enabled using Fnd_Log_Enable.",
    ],
    params: [
      ["text 1", "Text", "Text to add to the log."],
      ["text 2..text N", "Text", "Additional text to add to the log, optional."],
    ],
    examples: [
      ["Basic entry", `Fnd_Log_AddEntry ("Database launched.")`],
      ["Include caller", `Fnd_Log_AddEntry (Current method name;"Database launched.")`],
    ],
  },
  {
    name: "Fnd_Log_Enable",
    title: "Fnd_Log_Enable",
    signature: "Fnd_Log_Enable ({enable?}) -> Boolean",
    summary: "Turns original logging on or off and returns whether logging is enabled.",
    source: "Original Logging Component.pdf",
    body: [
      "By default, logging is turned off, so calling Fnd_Log_AddEntry has no effect.",
      "This command allows the developer to turn the logger on or off. Pass True to turn on logging, or False to turn it off.",
      "When logging is enabled, text passed to Fnd_Log_AddEntry is written to the log file.",
      "The log file is closed after each entry, so there is no need to turn off logging except to prevent Fnd_Log_AddEntry from writing to the log file.",
    ],
    params: [
      ["enable", "Boolean", "True to enable logging, optional."],
      ["Function result", "Boolean", "True if logging is enabled."],
    ],
    examples: [
      ["Turn logging on", `Fnd_Log_Enable (True)  \` Turn on logging.
Fnd_Log_AddEntry ("Database launched.")`],
      ["Read state", `$loggingEnabled_b:=Fnd_Log_Enable`],
    ],
  },
  {
    name: "Fnd_Log_Info",
    title: "Fnd_Log_Info",
    signature: "Fnd_Log_Info (info requested) -> Text",
    summary: "Returns requested information about the original component.",
    source: "Original Logging Component.pdf",
    body: [
      "Returns the requested information about the component.",
      "The original component can also be called using the Fnd_Gen_ComponentInfo method without first testing to see if the component is installed.",
    ],
    params: [
      ["info requested", "Text", "Information desired."],
      ["Function result", "Text", "Response."],
    ],
    extra: [
      ["Info requests", table(["Request", "Response", "Example"], [
        ["name", "The component's full name.", "Foundation Logging"],
        ["version", "The component's version number.", "4.0.5 beta 2"],
        ["logging", "Either \"enabled\" or \"disabled\".", "enabled"],
      ])],
    ],
    examples: [
      ["Read version", `$version_t:=Fnd_Log_Info ("version")`],
      ["Use Fnd_Gen_ComponentInfo", `$version_t:=Fnd_Gen_ComponentInfo ("Fnd_Log";"version")`],
    ],
  },
];

const evolutionMap = [
  ["Fnd_Log_AddEntry", "LOG ADD ENTRY", "The core idea remains: append one tab-delimited diagnostic row. The modern command adds levels, options objects, escaping, named-log routing, and destination metadata."],
  ["Fnd_Log_Enable", "LOG ENABLE", "Still process-local, but disabled logging now works with level thresholds so warnings and errors can continue to pass through."],
  ["Fnd_Log_Info", "Focused helper methods", "State that was previously returned as a broad information object is now exposed through focused methods such as Log Current Log, Log Current Label, Log File Name, Log Folder Path, Log Maximum Size, and LOG Level."],
  ["External tab-delimited file", "Destination bitmask", "The file remains the default destination. The current design adds ServerFile, 4D Record, and planned SQLite/offsite destinations."],
  ["Immediate file writes", "Batched writer worker", "Modern logs buffer by default and flush by interval, entry count, character threshold, explicit request, close, or writer shutdown."],
];

resetOutput();
copyOriginalDocs();

const allMethodNames = fs.readdirSync(docsDir)
  .filter((file) => file.endsWith(".md"))
  .map((file) => path.basename(file, ".md"))
  .filter((name) => name !== "Logging")
  .sort((a, b) => a.localeCompare(b));

const privateMethods = allMethodNames.filter((name) => !publicApi.includes(name) && !testSuite.includes(name));
const allPageNames = [...publicApi, ...privateMethods, ...testSuite].filter((name, index, list) => list.indexOf(name) === index);
const docs = Object.fromEntries(allMethodNames.map((name) => [name, readDoc(name)]));

const commandNamesForHighlight = [...allMethodNames, "Current method name", "Current method path", "String", "New object", "Count parameters", "Timestamp"];
const constantsForHighlight = [
  "True",
  "False",
  "Null",
  "Log Level Default",
  "Log Level Info",
  "Log Level Warn",
  "Log Level Error",
  "Log Flush Default",
  "Log Flush Real Time",
  "Logging Folder Path",
  "Logging File Suffix",
  "Logging End Of Line",
  "Logging Use Batch",
  "Logging Report Batch",
  "Logging Flush Interval",
  "Logging Flush Char Limit",
  "Logging Flush Entry Limit",
  "Logging Rollover Bytes",
  "Logging Archive Compressed",
  "Logging Include Machine Name",
  "Logging Destinations",
  "Log End Of Line CRLF",
  "Log End Of Line CR",
  "Log End Of Line LF",
  "Log File Suffix Text",
  "Log File Suffix Log",
  "Log to Default",
  "Log to LocalFile",
  "Log to ServerFile",
  "Log to 4D Record",
  "Log to SQLite",
  "Log to Offsite",
];
const keywords = ["var", "If", "Else", "End if", "Case of", "End case", "For", "End for", "Use", "End use", "Return", "#DECLARE"];

styles();
indexPage();
commandsPage();
originalDocsPage();
permissionPage();
legacyReference.forEach(legacyReferencePage);
allPageNames.forEach(methodPage);

console.log(`Wrote ${allPageNames.length + legacyReference.length + 5} documentation files into ${outDir}`);

function resetOutput() {
  fs.rmSync(commandsDir, { recursive: true, force: true });
  fs.rmSync(originalDir, { recursive: true, force: true });
  fs.rmSync(legacyDir, { recursive: true, force: true });
  fs.mkdirSync(commandsDir, { recursive: true });
  fs.mkdirSync(assetsDir, { recursive: true });
  fs.mkdirSync(originalDir, { recursive: true });
  fs.mkdirSync(legacyDir, { recursive: true });
}

function copyOriginalDocs() {
  originalDocs.map((doc) => doc.file).forEach((fileName) => {
    const source = path.join(sourceOriginalDir, fileName);
    if (fs.existsSync(source)) {
      fs.copyFileSync(source, path.join(originalDir, fileName));
    }
  });
}

function readDoc(name) {
  const file = path.join(docsDir, `${name}.md`);
  const raw = fs.existsSync(file) ? fs.readFileSync(file, "utf8").replace(/\r/g, "\n") : "";
  const withoutComment = raw.replace(/^<!--[\s\S]*?-->\s*/, "");
  const lines = withoutComment.split(/\n+/).map((line) => line.trim()).filter(Boolean);
  const titleIndex = lines.findIndex((line) => line.startsWith("## "));
  const title = titleIndex >= 0 ? lines[titleIndex].replace(/^##\s+/, "") : name;
  let signature = cleanText(lines[titleIndex + 1] ?? name);
  if (signature.length > 140 || /^var\s/i.test(signature) || signature.startsWith("/*") || signature.includes("); ")) {
    signature = name;
  }
  const attributes = cleanText(lines.find((line) => line.startsWith("Attributes:"))?.replace(/^Attributes:\s*/, "") ?? "");
  const attrIndex = lines.findIndex((line) => line.startsWith("Attributes:"));
  const description = cleanText(lines
    .slice(titleIndex + 2, attrIndex > -1 ? attrIndex : undefined)
    .filter((line) => !line.startsWith("|"))
    .join(" ")
    .replace(/\\_/g, "_"));
  const tableStart = lines.findIndex((line) => line.startsWith("|") && /Parameter|Parameters/.test(line));
  let params = [];
  if (tableStart > -1) {
    params = lines
      .slice(tableStart + 2)
      .filter((line) => line.startsWith("|"))
      .map((line) => line.split("|").slice(1, -1).map((cell) => cell.trim().replace(/\\_/g, "_")))
      .filter((cells) => cells.length > 1 && !cells.every((cell) => /^-+$/.test(cell)))
      .map((cells) => [cells[0] ?? "", cells[1] ?? "", cells[3] ?? cells[2] ?? ""]);
  }
  return { name, title, signature, attributes, description: clipDescription(description), params };
}

function methodPage(name) {
  const doc = docs[name] ?? readDoc(name);
  const publicDetail = detail[name];
  const group = publicApi.includes(name) ? "Public API" : testSuite.includes(name) ? "Test Suite" : "Private method";
  const params = publicDetail?.params ?? doc.params;
  const body = `    <article class="doc-page">
      <p class="eyebrow">${escapeHtml(group)}</p>
      <h1>${escapeHtml(name)}</h1>
      <p class="signature">${escapeHtml(publicDetail?.signature ?? doc.signature)}</p>
      <p class="lead">${escapeHtml(publicDetail?.summary ?? doc.description ?? "Internal support method.")}</p>
      ${doc.attributes ? `<p class="attributes">${escapeHtml(doc.attributes)}</p>` : ""}

      ${publicDetail ? publicDetail.body.map((paragraph) => `<p>${escapeHtml(paragraph)}</p>`).join("\n") : supportMethodBody(name, group, doc)}

      <section>
        <h2>Parameters</h2>
        ${paramTable(params)}
      </section>

      ${publicDetail?.extra?.map(([title, content]) => `<section><h2>${escapeHtml(title)}</h2>${sectionContent(content, { currentCommand: name })}</section>`).join("\n") ?? ""}

      ${publicDetail || group === "Test Suite" ? `<section>
        <h2>Code examples</h2>
        ${exampleBlocks(publicDetail?.examples ?? fallbackExamples(name), { currentCommand: name })}
      </section>` : ""}
    </article>`;
  fs.writeFileSync(path.join(commandsDir, `${slug(name)}.html`), layout({
    title: name,
    crumb: ["Commands", name],
    body,
    depth: "sub",
  }));
}

function supportMethodBody(name, group, doc) {
  if (group === "Test Suite") {
    return `<p>${escapeHtml(doc.description || "Test support method.")}</p><p>These methods are included to exercise the component rather than to form part of the normal application API. Run the suite method first when verifying changes to logging behaviour.</p>`;
  }
  return `<p>${escapeHtml(shortDescription(doc) || "Internal support method.")}</p><p>This method is an implementation detail used by the public API, documentation tooling, build process, or test harness. Application code should prefer the public API unless this project is being maintained directly.</p>`;
}

function sectionContent(content, codeOptions = {}) {
  if (typeof content === "string") return content;
  if (content?.code) return codeBlock(content.code, codeOptions);
  return "";
}

function warningBanner(title, body) {
  return `<div class="danger-banner" role="note">
        <strong>${escapeHtml(title)}</strong>
        <p>${escapeHtml(body)}</p>
      </div>`;
}

function fallbackExamples(name) {
  if (testSuite.includes(name)) {
    return [[`Run ${name}`, `${name}`]];
  }
  return [[`Call ${name}`, `${name}`]];
}

function indexPage() {
  const sampleLog = `2026-05-12  09:02:11  -      Startup        Database launched.
2026-05-12  09:02:18  info   Import         Customers imported  248
2026-05-12  09:02:22  warn   Audit          Customer changed    C1024`;
  const defaultCode = `// No configuration required for the default log.
LOG ENABLE(True)
LOG ADD ENTRY(Current method name; "Database launched.")

// Important entries can still be written while routine logging is disabled.
LOG ENABLE(False)
$currentLevel_i:=LOG Level(Log Level Warn)
LOG ADD ENTRY(Log Level Error; "Required data file missing")`;
  const destinationCode = `// Prepare the structured record destination once.
$result_o:=LOG CREATE TABLE

// After restart, declare logs with destination masks.
$options_o:=New object( \\
	Logging Destinations; Log to LocalFile+Log to ServerFile+Log to 4D Record; \\
	Logging Flush Interval; Log Flush Default; \\
	Logging Include Machine Name; True)

LOG DECLARE LOG("Audit"; "Audit.txt"; $logsFolder_t; $options_o)
LOG ADD ENTRY(New object("logLabel"; "Audit"; "logLevel"; Log Level Warn); \\
	"Customer changed"; "Customer"; $customerID_t)`;

  const body = `    <section class="hero">
      <h1>Logging component reference</h1>
      <div class="hero-actions">
        <a class="button" href="commands.html">Commands</a>
        <a class="button secondary" href="original.html">Original docs</a>
        <a class="button secondary" href="permission.html">Original release permission</a>
      </div>
    </section>

    <section class="two-col">
      <div>
        <h2>Introduction</h2>
        <p>This component appends text entries to external log files. That makes it useful when diagnosing intermittent database problems, especially faults that happen shortly before an application crash or forced shutdown.</p>
        <p>A single call to <code>LOG ADD ENTRY</code> adds one row. Text parameters are written as tab-delimited columns after the automatic timestamp and level columns. Passing <code>Current method name</code> as the first text value is a practical way to record where an entry came from.</p>
      </div>
      <div>${codeBlock(sampleLog, { commandHrefPrefix: "commands/" })}</div>
    </section>

    <section class="two-col">
      <div>
        <h2>Default Behaviour</h2>
        <p>Without configuration, the component initialises on first use. The default log file is named after the structure file, followed by <code> log.txt</code>, and is placed in 4D's Logs folder.</p>
        <p>Batching is enabled by default. The writer flushes when asked explicitly, when a real-time log is used, when the buffer reaches about 64,000 characters, when it reaches 1,000 entries, when the nine-second interval elapses, or when the log is closed or the writer is stopped.</p>
        <p>When batch reporting is enabled, each batch write adds a labelled diagnostic row showing the cause, entry count, character count, and elapsed milliseconds since the previous batch write.</p>
        <p>Rollover is disabled by default. If rollover is later enabled, archived files are compressed after the writer moves the old log file aside.</p>
        <p>The enabled state starts as <code>False</code> for each process. In the modern component, disabled logging still allows entries at or above the effective log level. With untouched defaults, the threshold is <code>Log Level Default</code>. To suppress routine entries while still allowing warnings or errors, set a higher threshold with <code>LOG Level</code>.</p>
      </div>
      <div>${codeBlock(defaultCode, { commandHrefPrefix: "commands/" })}</div>
    </section>

    <section>
      <h2>Configuration</h2>
      <p><code>LOG CONFIG</code> changes application-wide defaults for future log declarations. It is normally called during startup, before named logs are declared.</p>
      ${table(["Option", "Default", "Purpose"], configOptions.map(([constant, , , defaultValue, explanation]) => [constant, defaultValue, explanation]))}
      <p><a class="button secondary" href="commands/log-config.html">Read the LOG CONFIG reference</a></p>
    </section>

    <section>
      <h2>Destinations</h2>
      ${warningBanner(destinationWarning.title, destinationWarning.body)}
      <p>Declared logs can write to one or more destinations by combining destination constants. LocalFile is the default. ServerFile writes the client-rendered line on the server in client/server deployments. 4D Record writes structured records when the <code>Logging</code> table exists.</p>
      ${table(["Destination", "Value", "Behaviour"], destinations)}
      <p><code>Log to SQLite</code> currently has partial 4D-side dispatch and batch-posting code, but the external helper service has not been built, packaged, or installed by the component yet. <code>Log to Offsite</code> is a reserved destination only.</p>
      <p>The current SQLite design is server-mediated in client/server deployments: client calls enter 4D Server, and 4D Server posts batches to a local helper service. Direct client-to-helper delivery remains future design work.</p>
    </section>

    <section class="two-col">
      <div>
        <h2>Record Setup</h2>
        <p><code>LOG CREATE TABLE</code> creates the <code>Logging</code> table and indexes if they are missing. When it creates the table, restart or reopen the database before sending entries to <code>Log to 4D Record</code>.</p>
        <p>When <code>Logging Include Machine Name</code> is enabled, LocalFile and ServerFile rows include the client machine name immediately after the timestamp. Structured entries also carry UTC timestamp and process name metadata for destination handlers.</p>
      </div>
      <div>${codeBlock(destinationCode, { commandHrefPrefix: "commands/" })}</div>
    </section>

    <section class="permission-callout">
      <div>
        <p class="eyebrow">Original documentation</p>
        <h2>From Foundation Logging to the current component</h2>
        <p>Dave Batton's original developer reference and 2005 release announcement are included so maintainers can see the source design and how the current API evolved from it.</p>
      </div>
      <a class="button secondary" href="original.html">Open original docs</a>
    </section>`;

  fs.writeFileSync(path.join(outDir, "index.html"), layout({
    title: "Home",
    crumb: [],
    body,
    depth: "root",
    isHome: true,
  }));
}

function commandsPage() {
  const body = `    <article class="doc-page wide">
      <h1>Commands</h1>
      <p class="lead">The public API is intended for application code. Private methods support the writer, configuration, documentation, build, and compatibility internals. The test suite methods verify component behaviour.</p>
      ${commandSection("Public API", publicApi)}
      ${commandSection("Private methods", privateMethods)}
      ${commandSection("Test Suite", testSuite)}
    </article>`;

  fs.writeFileSync(path.join(outDir, "commands.html"), layout({
    title: "Commands",
    crumb: ["Commands"],
    body,
    depth: "root",
  }));
}

function originalDocsPage() {
  const docRows = originalDocs.map((doc) => [
    `<a href="${originalHref(doc.file)}">${escapeHtml(doc.title)}</a>`,
    escapeHtml(doc.description),
  ]);
  const referenceRows = legacyReference.map((page) => [
    `<a href="original-reference/${slug(page.name)}.html">${escapeHtml(page.title)}</a>`,
    `<code>${escapeHtml(page.signature)}</code>`,
    escapeHtml(page.summary),
  ]);
  const body = `    <article class="doc-page wide">
      <p class="eyebrow">Project history</p>
      <h1>Original Foundation Logging documentation</h1>
      <p class="lead">This page keeps Dave Batton's original documentation beside the current reference, so developers can see the component's source design and what it has become.</p>

      <section>
        <h2>Original files</h2>
        <p>The PDF files are copied into this About site when it is generated, so they remain available from a built component without requiring the repository's <code>Documentation</code> folder.</p>
        ${table(["Document", "Purpose"], docRows, true)}
      </section>

      <section>
        <h2>How the design evolved</h2>
        <p>The current component keeps the original small logging surface, but changes the implementation shape for modern 4D projects, named logs, level filtering, batching, test coverage, and destination routing.</p>
        ${table(["Original idea", "Current form", "Evolution"], evolutionMap)}
      </section>

      <section>
        <h2>Original reference</h2>
        <p>The original manual is reproduced as readable HTML pages in this section, with a different visual treatment from the current command reference. Use the PDF above when exact pagination or typography matters.</p>
        ${table(["Page", "Original signature", "Description"], referenceRows, true)}
      </section>
    </article>`;

  fs.writeFileSync(path.join(outDir, "original.html"), layout({
    title: "Original Documentation",
    crumb: ["Original Documentation"],
    body,
    depth: "root",
    pageClass: "legacy-section",
  }));
}

function legacyReferencePage(page) {
  const body = `    <article class="doc-page legacy-doc">
      <p class="eyebrow">Original reference</p>
      <h1>${escapeHtml(page.title)}</h1>
      <p class="signature">${escapeHtml(page.signature)}</p>
      <p class="lead">${escapeHtml(page.summary)}</p>
      <p class="attributes">Transcribed from ${escapeHtml(page.source)}</p>

      ${page.body.map((paragraph) => `<p>${escapeHtml(paragraph)}</p>`).join("\n")}

      ${page.params ? `<section>
        <h2>Parameters</h2>
        ${paramTable(page.params)}
      </section>` : ""}

      ${page.extra?.map(([title, content]) => `<section><h2>${escapeHtml(title)}</h2>${sectionContent(content, { commandHrefPrefix: "../commands/" })}</section>`).join("\n") ?? ""}

      ${page.examples ? `<section>
        <h2>Code examples</h2>
        ${exampleBlocks(page.examples, { commandHrefPrefix: "../commands/" })}
      </section>` : ""}
    </article>`;

  fs.writeFileSync(path.join(legacyDir, `${slug(page.name)}.html`), layout({
    title: page.title,
    crumb: ["Original Documentation", page.title],
    body,
    depth: "sub",
    pageClass: "legacy-section",
  }));
}

function commandSection(title, names) {
  const rows = names
    .filter((name) => docs[name])
    .map((name) => {
      const publicDetail = detail[name];
      const doc = docs[name];
      return [
        `<a href="commands/${slug(name)}.html">${escapeHtml(name)}</a>`,
        `<code>${escapeHtml(publicDetail?.signature ?? doc.signature)}</code>`,
        escapeHtml(publicDetail?.summary ?? shortDescription(doc) ?? ""),
      ];
    });
  return `<section><h2>${escapeHtml(title)}</h2>${table(["Name", "Signature", "Description"], rows, true)}</section>`;
}

function permissionPage() {
  const body = `    <article class="doc-page">
      <p class="eyebrow">Original release notice</p>
      <h1>${escapeHtml(permission.title)}</h1>
      <p class="lead">Transcribed from <code>Documentation/Original/[ANN] Free Foundation 4 Logging Component Released.pdf</code>.</p>
      <section class="email-card">
        <dl class="email-meta">
          <div><dt>From</dt><dd>${escapeHtml(permission.from)}</dd></div>
          <div><dt>Reply-To</dt><dd>${escapeHtml(permission.replyTo)}</dd></div>
          <div><dt>To</dt><dd>${escapeHtml(permission.to)}</dd></div>
          <div><dt>Date</dt><dd>${escapeHtml(permission.date)}</dd></div>
        </dl>
        <div class="email-body">
          ${permission.body.map((paragraph) => `<p>${escapeHtml(paragraph)}</p>`).join("")}
          <ul class="email-links">${permission.links.map((link) => `<li><a href="${escapeHtml(link)}">${escapeHtml(link)}</a></li>`).join("")}</ul>
          <p class="signature-block">--<br>${escapeHtml(permission.signature)}<br><a href="http://www.FoundationShell.com/">http://www.FoundationShell.com/</a></p>
        </div>
      </section>
    </article>`;
  fs.writeFileSync(path.join(outDir, "permission.html"), layout({
    title: "Original Release Permission",
    crumb: ["Original Release Permission"],
    body,
    depth: "root",
    pageClass: "legacy-section",
  }));
}

function layout({ title, crumb, body, depth, isHome = false, pageClass = "" }) {
  const prefix = depth === "sub" ? "../" : "";
  const breadcrumb = renderBreadcrumb(crumb, prefix, isHome);
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)} - Logging Component</title>
  <link rel="stylesheet" href="${prefix}assets/styles.css">
</head>
<body${pageClass ? ` class="${escapeHtml(pageClass)}"` : ""}>
  <header class="site-header">
    <nav class="breadcrumb" aria-label="Breadcrumb">${breadcrumb}</nav>
    <div class="masthead">
      <a class="brand" href="${prefix}index.html">Logging Component</a>
      <div class="top-links">
        <a href="${prefix}index.html">Overview</a>
        <a href="${prefix}commands.html">Commands</a>
        <a href="${prefix}original.html">Original Docs</a>
        <a href="${prefix}permission.html">Permission</a>
      </div>
    </div>
  </header>
  <main class="page-shell">
${body}
  </main>
</body>
</html>
`;
}

function renderBreadcrumb(crumb, prefix, isHome) {
  if (isHome) return `<span aria-current="page">Home</span>`;

  const home = `<a href="${prefix}index.html">Home</a>`;
  return home + crumb.map((item, index) => {
    const isCurrent = index === crumb.length - 1;
    const label = typeof item === "string" ? item : item.label;
    const href = isCurrent ? "" : breadcrumbHref(item, prefix);
    const text = escapeHtml(label);
    const content = href
      ? `<a href="${href}">${text}</a>`
      : `<span aria-current="page">${text}</span>`;
    return `<span class="sep">/</span>${content}`;
  }).join("");
}

function breadcrumbHref(item, prefix) {
  if (typeof item === "object" && item?.href) return `${prefix}${item.href}`;

  switch (item) {
    case "Commands":
      return `${prefix}commands.html`;
    case "Original Documentation":
      return `${prefix}original.html`;
    case "Original Release Permission":
      return `${prefix}permission.html`;
    default:
      return "";
  }
}

function paramTable(rows) {
  if (!rows || rows.length === 0) return `<p class="muted">This command does not require parameters.</p>`;
  return table(["Parameter", "Type", "Description"], rows.map((row) => row.map(escapeHtml)), true);
}

function table(headers, rows, trusted = false) {
  return `<div class="table-wrap"><table>
    <thead><tr>${headers.map((header) => `<th>${escapeHtml(header)}</th>`).join("")}</tr></thead>
    <tbody>${rows.map((row) => `<tr>${row.map((cell) => `<td>${trusted ? cell : escapeHtml(cell)}</td>`).join("")}</tr>`).join("")}</tbody>
  </table></div>`;
}

function exampleBlocks(examples, codeOptions = {}) {
  return examples.map(([title, code]) => `<div class="example"><h3>${escapeHtml(title)}</h3>${codeBlock(code, codeOptions)}</div>`).join("");
}

function codeBlock(code, codeOptions = {}) {
  return `<pre class="code"><code>${code.split("\n").map((line) => highlightLine(line, codeOptions)).join("\n")}</code></pre>`;
}

function highlightLine(line, codeOptions = {}) {
  const commentIndex = findLineCommentIndex(line);
  const codePart = commentIndex > -1 ? line.slice(0, commentIndex) : line;
  const comment = commentIndex > -1 ? line.slice(commentIndex) : "";
  const code = codePart.split(/("[^"]*")/g).map((part) => {
    if (part.startsWith('"') && part.endsWith('"')) return `<span class="tok-string">${escapeHtml(part)}</span>`;
    return highlightCodeSegment(part, codeOptions);
  }).join("");
  return code + (comment ? `<span class="tok-comment">${escapeHtml(comment)}</span>` : "");
}

function findLineCommentIndex(line) {
  let inString = false;
  for (let index = 0; index < line.length - 1; index += 1) {
    if (line[index] === '"') inString = !inString;
    if (!inString && line[index] === "/" && line[index + 1] === "/") return index;
  }
  return -1;
}

function highlightCodeSegment(segment, codeOptions = {}) {
  let code = escapeHtml(segment);
  code = replaceOutsideTags(code, /\b(\d+)\b/g, '<span class="tok-number">$1</span>');
  code = replaceOutsideTags(code, /\$[A-Za-z0-9_{}]+/g, '<span class="tok-local">$&</span>');
  code = replaceOutsideTags(code, /\b(Storage|lg)\b/g, '<span class="tok-interprocess">$1</span>');
  code = replaceOutsideTags(code, /\.([A-Za-z][A-Za-z0-9_]*)/g, '.<span class="tok-attribute">$1</span>');
  for (const keyword of keywords.sort((a, b) => b.length - a.length)) {
    code = replaceOutsideTags(code, new RegExp(`\\b${escapeRegExp(keyword)}\\b`, "g"), `<span class="tok-keyword">${escapeHtml(keyword)}</span>`);
  }
  for (const constant of constantsForHighlight.sort((a, b) => b.length - a.length)) {
    code = replaceOutsideTags(code, new RegExp(`\\b${escapeRegExp(constant)}\\b`, "g"), `<span class="tok-constant">${escapeHtml(constant)}</span>`);
  }
  for (const method of commandNamesForHighlight.sort((a, b) => b.length - a.length)) {
    code = replaceOutsideTags(code, new RegExp(`\\b${escapeRegExp(method)}\\b`, "g"), commandTokenHtml(method, codeOptions));
  }
  return code;
}

function commandTokenHtml(method, codeOptions = {}) {
  const label = escapeHtml(method);
  if (method === codeOptions.currentCommand) return `<span class="tok-command">${label}</span>`;
  if (!allMethodNames.includes(method)) return `<span class="tok-command">${label}</span>`;

  const prefix = codeOptions.commandHrefPrefix ?? "";
  return `<a class="tok-command code-command-link" href="${prefix}${slug(method)}.html">${label}</a>`;
}

function replaceOutsideTags(html, pattern, replacer) {
  return html.split(/(<[^>]+>)/g).map((part) => (part.startsWith("<") ? part : part.replace(pattern, replacer))).join("");
}

function slug(name) {
  return name.toLowerCase().replace(/_/g, "-").replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

function originalHref(fileName) {
  return `original/${fileName.split("/").map(encodeURIComponent).join("/")}`;
}

function shortDescription(doc) {
  return clipDescription(cleanText(doc.description || ""));
}

function clipDescription(text) {
  if (!text) return "";
  if (text.length <= 260) return text;
  return `${text.slice(0, 257).trim()}...`;
}

function cleanText(value) {
  return String(value)
    .replace(/\\_/g, "_")
    .replace(/\s+/g, " ")
    .replace(/\bbehavior\b/g, "behaviour")
    .replace(/\bBehavior\b/g, "Behaviour")
    .replace(/\bInitializes\b/g, "Initialises")
    .replace(/\binitializes\b/g, "initialises")
    .replace(/\bInitialized\b/g, "Initialised")
    .replace(/\binitialized\b/g, "initialised")
    .replace(/\bserialized\b/g, "serialised")
    .replace(/\bSerialized\b/g, "Serialised")
    .trim();
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function styles() {
  fs.writeFileSync(path.join(assetsDir, "styles.css"), `:root {
  color-scheme: light;
  --bg: #f5f6f7;
  --panel: #ffffff;
  --ink: #202124;
  --muted: #666d76;
  --rule: #d3d7dd;
  --soft: #eceff3;
  --accent: #0b7f24;
  --accent-dark: #075b1b;
  --link: #0b55c4;
  --code-bg: #fbfbfc;
  --code-border: #cfd3d8;
}

* { box-sizing: border-box; }

body {
  margin: 0;
  background: var(--bg);
  color: var(--ink);
  font: 16px/1.55 -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif;
}

body.legacy-section {
  --bg: #eef7f3;
  --panel: #fbfffd;
  --rule: #b8d8ca;
  --soft: #dcece5;
  --accent: #0a6b55;
  --accent-dark: #064a3c;
  --link: #075f88;
  --code-bg: #f8fffb;
  --code-border: #b8d8ca;
}

a { color: var(--link); text-decoration: none; }
a:hover { text-decoration: underline; }

.site-header {
  position: sticky;
  top: 0;
  z-index: 10;
  border-bottom: 1px solid var(--rule);
  background: rgba(245, 246, 247, 0.96);
}

.breadcrumb,
.masthead,
.page-shell {
  max-width: 1180px;
  margin: 0 auto;
  padding-left: 24px;
  padding-right: 24px;
}

.breadcrumb {
  padding-top: 10px;
  color: var(--muted);
  font-size: 13px;
}

.breadcrumb .sep { padding: 0 8px; color: #99a0aa; }

.masthead {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  min-height: 56px;
  gap: 20px;
}

.brand { color: var(--ink); font-weight: 700; }

.top-links {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  font-size: 14px;
}

.page-shell { padding-top: 32px; padding-bottom: 56px; }

.hero {
  padding: 34px 0 42px;
  border-bottom: 1px solid var(--rule);
}

.hero h1 {
  max-width: 900px;
  margin: 0 0 20px;
  font-size: clamp(42px, 7vw, 80px);
  line-height: 0.98;
  letter-spacing: 0;
}

.hero-actions,
.permission-callout {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
}

.button {
  display: inline-flex;
  align-items: center;
  min-height: 38px;
  padding: 7px 13px;
  border: 1px solid var(--accent);
  border-radius: 6px;
  background: var(--accent);
  color: white;
  font-weight: 700;
}

.button.secondary { background: white; color: var(--accent-dark); }

section { margin-top: 42px; }
h1, h2, h3 { letter-spacing: 0; }
h1 { margin: 0 0 8px; font-size: 46px; line-height: 1.05; }
h2 { margin: 0 0 14px; font-size: 26px; }
h3 { margin: 0 0 10px; font-size: 18px; }

.lead {
  max-width: 790px;
  color: #424851;
  font-size: 20px;
}

.eyebrow {
  margin: 0 0 12px;
  color: var(--accent-dark);
  font-size: 13px;
  font-weight: 800;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.two-col {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1.25fr);
  gap: 28px;
  align-items: start;
}

.permission-callout {
  justify-content: space-between;
  padding: 22px;
  border: 1px solid var(--rule);
  border-radius: 8px;
  background: var(--panel);
}

.danger-banner {
  margin: 16px 0 18px;
  padding: 14px 16px;
  border: 2px solid #b00020;
  border-radius: 8px;
  background: #fff1f1;
  color: #5f0011;
}

.danger-banner strong {
  display: block;
  margin-bottom: 4px;
  color: #b00020;
  font-size: 17px;
}

.danger-banner p {
  margin: 0;
}

.doc-page { max-width: 980px; }
.doc-page.wide { max-width: none; }
.legacy-doc {
  padding: 24px;
  border: 1px solid var(--rule);
  border-radius: 8px;
  background: rgba(251, 255, 253, 0.82);
}

.signature,
code,
.code {
  font-family: "Courier Prime", "SFMono-Regular", Consolas, "Liberation Mono", monospace;
}

.signature {
  display: inline-block;
  margin: 4px 0 12px;
  padding: 5px 8px;
  border: 1px solid var(--rule);
  border-radius: 6px;
  background: var(--panel);
  font-size: 14px;
}

.attributes {
  display: inline-block;
  margin: 0 0 14px;
  padding: 5px 8px;
  border-radius: 999px;
  background: #e8f2ea;
  color: var(--accent-dark);
  font-size: 13px;
  font-weight: 700;
}

.table-wrap {
  overflow-x: auto;
  border: 1px solid var(--rule);
  border-radius: 8px;
  background: var(--panel);
}

table { width: 100%; border-collapse: collapse; }
th, td { padding: 10px 12px; border-bottom: 1px solid var(--soft); text-align: left; vertical-align: top; }
th { color: #4d535c; font-size: 13px; text-transform: uppercase; }
tr:last-child td { border-bottom: 0; }

.code {
  overflow-x: auto;
  margin: 0;
  padding: 14px 16px;
  border: 1px solid var(--code-border);
  border-radius: 8px;
  background: var(--code-bg);
  color: #000;
  font-size: 14px;
  line-height: 1.45;
  tab-size: 4;
}

.example { margin-top: 18px; }
.tok-command { color: #008a00; font-weight: 800; }
.code a.code-command-link,
.code a.code-command-link:hover {
  color: #008a00;
  text-decoration: none;
}
.tok-comment { color: #55575c; }
.tok-constant { color: #4b0058; text-decoration: underline; }
.tok-keyword { color: #005900; font-weight: 800; }
.tok-local { color: #2457b8; }
.tok-interprocess { color: #f00092; }
.tok-attribute { color: #9a7d6d; }
.tok-string, .tok-number { color: #000; }

.email-card {
  border: 1px solid var(--rule);
  border-radius: 8px;
  background: var(--panel);
}

.email-meta {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  margin: 0;
  border-bottom: 1px solid var(--rule);
}

.email-meta div { padding: 12px 14px; border-right: 1px solid var(--soft); border-bottom: 1px solid var(--soft); }
.email-meta dt { color: var(--muted); font-size: 12px; font-weight: 700; text-transform: uppercase; }
.email-meta dd { margin: 2px 0 0; }
.email-body { max-width: 790px; padding: 18px 22px 22px; }
.email-links { padding-left: 20px; }
.signature-block { margin-top: 32px; color: #515761; }
.muted { color: var(--muted); }

@media (max-width: 760px) {
  .two-col,
  .email-meta { grid-template-columns: 1fr; }
  .masthead { align-items: flex-start; flex-direction: column; padding-top: 12px; padding-bottom: 12px; }
  .hero h1 { font-size: 42px; }
  h1 { font-size: 36px; }
}
`);
}
