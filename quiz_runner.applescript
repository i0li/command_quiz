#!/usr/bin/osascript

-- ============================
-- ハンドラ定義
-- ============================

on getUserInput(question, answer, showHint)
	if showHint then
		set promptText to question & "\n\n👀 " & answer
	else
		set promptText to question
	end if

	set userInput to text returned of (display dialog promptText default answer "")
	return userInput
end getUserInput

on handleIncorrect(showHint)
	if showHint then
		return true
	else
		set action to text returned of (display dialog "any key : retry\ns : show answer" default answer "")
		if action is "s" then
			return true
		else
			return false
		end if
	end if
end handleIncorrect

-- ============================
-- メイン処理
-- ============================

on run argv
	set question to item 1 of argv
	set answer to item 2 of argv

	set startTime to do shell script "date '+%Y-%m-%d %H:%M:%S'"

	set correct to false
	set showHint to false

	set answersLog to {}

	repeat until correct
		set userInput to getUserInput(question, answer, showHint)

		if showHint then
			set prefix to "[Hint]"
		else
			set prefix to "[ -- ]"
		end if

		if userInput is equal to answer then
			set correct to true
			set end of answersLog to prefix & userInput
		else
			set end of answersLog to prefix & userInput
			set showHint to handleIncorrect(showHint)
		end if
	end repeat

	-- ============================
	-- ログ生成
	-- ============================

	set indent to "    "
	set newLine to "\n"
	set endLine to "----------------------------------------"

	set logText to "[" & startTime & "]" & newLine
	set logText to logText & "question: " & question & newLine
	set logText to logText & "answer  : " & answer & newLine

	repeat with a in answersLog
		set logText to logText & indent & (contents of a) & newLine
	end repeat

	set logText to logText & endLine & newLine

	return logText
end run
