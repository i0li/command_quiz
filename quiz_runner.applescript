#!/usr/bin/osascript

-- YAML ファイルパス
set filePath to POSIX path of (path to home folder) & "workspace/command-quiz/questions.yaml"

-- ============================
-- ハンドラ定義
-- ============================

on getRandomQuestion(filePath)
	set total to (do shell script "yq length " & quoted form of filePath)
	set randomIndex to (random number from 1 to total) as integer
	set yqIndex to randomIndex - 1
	
	set question to do shell script "yq '.[ " & yqIndex & " ].q' " & quoted form of filePath
	set answer to do shell script "yq '.[ " & yqIndex & " ].a' " & quoted form of filePath
	
	return {question, answer}
end getRandomQuestion

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

-- 開始時間
set startTime to do shell script "date '+%Y-%m-%d %H:%M:%S'"

set qAndA to getRandomQuestion(filePath)
set question to item 1 of qAndA
set answer to item 2 of qAndA

set correct to false
set showHint to false

-- 回答履歴
set answersLog to {}

repeat until correct
	set userInput to getUserInput(question, answer, showHint)
	
	-- プレフィックス決定
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
