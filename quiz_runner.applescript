#!/usr/bin/osascript

-- ============================
-- ハンドラ定義
-- ============================

-- TSV用のエスケープ処理
on escapeTSV(str)
	-- タブと改行をエスケープ
	set str to replaceText(str, tab, "\\t")
	set str to replaceText(str, return, "\\n")
	set str to replaceText(str, linefeed, "\\n")
	return str
end escapeTSV

-- テキスト置換用ハンドラ
on replaceText(theText, searchStr, replaceStr)
	set AppleScript's text item delimiters to searchStr
	set textItems to text items of theText
	set AppleScript's text item delimiters to replaceStr
	set theText to textItems as text
	set AppleScript's text item delimiters to ""
	return theText
end replaceText

on getUserInput(question, answer, showHint, isRetry)
	-- プロンプトテキスト構築
	if showHint then
		-- ヒント表示時（ヒントが見えているので案内不要）
		set promptText to question & "\n\n💡 " & answer
	else if isRetry then
		-- 不正解時（不正解であることはモーダル再表示でわかるので文言不要）
		set promptText to question & "\n\n[?:Hint]"
	else
		-- 初回表示
		set promptText to question & "\n\n[?:Hint]"
	end if

	set userInput to text returned of (display dialog promptText default answer "")
	return userInput
end getUserInput

-- ============================
-- メイン処理
-- ============================

on run argv
	set question to item 1 of argv
	set answer to item 2 of argv

	set correct to false
	set showHint to false
	set isRetry to false

	set attemptsList to {}

	repeat until correct
		set userInput to getUserInput(question, answer, showHint, isRetry)

		-- "?" でヒント要求（カウントしない、ログに記録しない）
		if userInput is "?" then
			set showHint to true
			-- 次のループでヒント付きで表示（attemptsListには追加しない）
		else
			-- 通常の回答として処理
			set attemptRecord to {input:userInput, hint:showHint, correct:(userInput is equal to answer)}
			set end of attemptsList to attemptRecord

			if userInput is equal to answer then
				set correct to true
				-- 正解時は何も表示せずに終了
			else
				-- 不正解の場合、次回はリトライモード（モーダルが再表示される）
				set isRetry to true
				-- showHintはそのまま維持（一度ヒント表示したら継続）
			end if
		end if
	end repeat

	-- TSV形式で出力
	set tsvOutput to ""
	set LF to ASCII character 10 -- Linefeed (改行)

	-- メタデータ（質問と答え）
	set tsvOutput to tsvOutput & "META" & tab & "question" & tab & escapeTSV(question) & LF
	set tsvOutput to tsvOutput & "META" & tab & "answer" & tab & escapeTSV(answer) & LF

	-- 試行データ（"?"入力は含まれない）
	set attemptNum to 1
	repeat with attempt in attemptsList
		set tsvOutput to tsvOutput & "ATTEMPT" & tab & attemptNum & tab
		set tsvOutput to tsvOutput & escapeTSV(input of attempt) & tab
		set tsvOutput to tsvOutput & (hint of attempt) & tab
		set tsvOutput to tsvOutput & (correct of attempt) & LF
		set attemptNum to attemptNum + 1
	end repeat

	return tsvOutput
end run