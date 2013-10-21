dofile("string.lua")

-- -------------------------
-- LUANET
-- -------------------------
System = luanet.System
Forms = System.Windows.Forms

if luanet then
	if ___GIsServer then
		-- �������Զ�������ȫ�����þ�Ĭ��ʽ
		io.MessageBox = luanet.System.Console.WriteLine
		io.MessageBoxResult = function() end
	else
		-- ��Ϣ��, ����ͣ�ű�ִ��, ֱ�������ť
		io.MessageBox = luanet.System.Windows.Forms.MessageBox.Show
		
		-- �����ص���Ϣ��, ����ͣ�ű�ִ��, ֱ�������ť
		io.MessageBoxResult = function(szContent, szTitle)
			szTitle = szTitle or "��ʾ"
			local lnMessageBox = luanet.System.Windows.Forms.MessageBox
			local lnMessageBoxButtons = luanet.System.Windows.Forms.MessageBoxButtons
			local lnDialogResult = luanet.System.Windows.Forms.DialogResult
			local lnMessageBoxIcon = luanet.System.Windows.Forms.MessageBoxIcon
			if lnMessageBox.Show(szContent, szTitle, lnMessageBoxButtons.YesNo, lnMessageBoxIcon.Question) == lnDialogResult.Yes then
				return true
			else
				return false
			end
		end
		
		-- ����һ������LOG�Ĵ���
		PAGES_NAME = {"ȫ�ֵ�����Ϣ", "���й淶", "��ر���", "�������ո�淶", "����ֵ�淶", "�����淶", "ħ������", "*�汾˵��*"}
		io.CreateOutputForm = function(OutputFunction, CommentFunction, IndentFunction)
			local lnOutputForm = Forms.Form();lnOutputForm:SuspendLayout();
			local lnTabControl = Forms.TabControl();lnTabControl:SuspendLayout();
			local lntTabPages = {}
			local lntRichTextBoxs = {}
			for i = 1, #PAGES_NAME do
				lntTabPages[i] = Forms.TabPage();lntTabPages[i]:SuspendLayout();
				lntRichTextBoxs[i] = Forms.RichTextBox()
			end
			local lnButtonWrite = Forms.Button()
			local lnButtonCancel = Forms.Button()
			local lnButtonComment = Forms.Button()
			local lnButtonIndent = Forms.Button()
			local tProtectedObj = {}
			
			-- TabControl �ؼ�
			lnTabControl.Location = System.Drawing.Point(13, 13)
			lnTabControl.Name = "TabControl"
			lnTabControl.SelectedIndex = 0
			lnTabControl.Size = System.Drawing.Size(769, 514)
			lnTabControl.TabIndex = 0
			for i = 1, #PAGES_NAME do
				lntTabPages[i].Name = "TabPage" .. i
				lntTabPages[i].Padding = Forms.Padding(3)
				lntTabPages[i].Size = System.Drawing.Size(761, 489)
				lntTabPages[i].TabIndex = 0
				lntTabPages[i].Text = PAGES_NAME[i]
				lntTabPages[i].UseVisualStyleBackColor = true
			
				-- PAGE�ڵ�TEXTBOX
				lntRichTextBoxs[i].Dock = Forms.DockStyle.Fill
				lntRichTextBoxs[i].Location = System.Drawing.Point(3, 3)
				lntRichTextBoxs[i].Name = "RichTextBox" .. i
				lntRichTextBoxs[i].Size = System.Drawing.Size(755, 483)
				lntRichTextBoxs[i].TabIndex = 0
				lntRichTextBoxs[i].Text = ""
				lntRichTextBoxs[i].MouseDoubleClick:Add(function(sender, data)
					local nSelectionStart = sender.SelectionStart
					local nCount = 0
					for i = 1, #sender.Text do
						if sender.Text:sub(i, i):byte() > 127 then
							nCount = nCount + 1
						else
							nCount = nCount + 2
						end
						if nCount % 2 == 0 and math.floor(nCount / 2) == nSelectionStart then
							nSelectionStart = i + 1
							break
						end
					end
					local szTemp = sender.Text:sub(1, nSelectionStart)
					local nLineStart = 1
					local nLineEnd = 1
					for i = #szTemp - 1, 1, -1 do
						if szTemp:sub(i, i) == "\n" then
							nLineStart = i + 1
							szTemp = szTemp:sub(nLineStart, nSelectionStart)
							break
						end
					end
					for i = nLineStart, #sender.Text, 1 do
						if sender.Text:sub(i, i) == "\n" then
							nLineEnd = i
							break
						end
					end
					if nLineEnd == 1 then
						nLineEnd = #sender.Text
					end
					szTemp = sender.Text:sub(nLineStart, nLineEnd)
					
					szLineCount = szTemp:match("Line (%d+) :")
					if szLineCount then
						local codepage = this.ActiveMdiChild.luaEdit1
						codepage.ce1:GotoLine(tonumber(szLineCount) - 1)
						codepage:Focus()
					end
				end)
				
				lntTabPages[i].Controls:Add(lntRichTextBoxs[i])						-- �ҽӿؼ�
				lnTabControl.Controls:Add(lntTabPages[i])							-- �ҽӿؼ�
		    end
			
			-- OutputForm ����
			lnOutputForm.StartPosition = Forms.FormStartPosition.CenterScreen		-- ��ʼλ��, ����
			lnOutputForm.AutoScaleMode = Forms.AutoScaleMode.None					-- �Զ����Źر�
			lnOutputForm.ClientSize = System.Drawing.Size(794, 568)					-- ��������(800, 600)
			lnOutputForm.FormBorderStyle = Forms.FormBorderStyle.FixedDialog		-- �̶���С
			lnOutputForm.Opacity = 0.9
			lnOutputForm.MaximizeBox = false
            lnOutputForm.MinimizeBox = false
            lnOutputForm.CancelButton = lnButtonCancel
            lnOutputForm.KeyPreview = true
			lnOutputForm.Name = "OutputForm"
			lnOutputForm.Text = "�ű����LOG�������"
			lnOutputForm:ResumeLayout(false)
			lnOutputForm.Controls:Add(lnTabControl)									-- �ҽӿؼ�
			lnOutputForm.Controls:Add(lnButtonWrite)								-- �ҽӿؼ�
			lnOutputForm.Controls:Add(lnButtonCancel)								-- �ҽӿؼ�
			lnOutputForm.Controls:Add(lnButtonComment)								-- �ҽӿؼ�
			lnOutputForm.Controls:Add(lnButtonIndent)								-- �ҽӿؼ�
			lnOutputForm.KeyUp:Add(function(sender, data)							-- ESC �رմ���
				if data.KeyCode == Forms.Keys.Escape then
					sender:Dispose()
				end
			end)
			
			-- ButtonCancel �ؼ�
			lnButtonCancel.Location = System.Drawing.Point(700, 533)
			lnButtonCancel.Name = "ButtonCancel"
			lnButtonCancel.Size = System.Drawing.Size(75, 23)
			lnButtonCancel.TabIndex = 1
			lnButtonCancel.Text = "�˳� [ESC]"
			lnButtonCancel.UseVisualStyleBackColor = true
			lnButtonCancel.DialogResult = Forms.DialogResult.Cancel
			lnButtonCancel.MouseClick:Add(function(sender, data) sender.Parent:Dispose() end)
			
			-- ButtonWrite �ؼ�
			lnButtonWrite.Location = System.Drawing.Point(619, 533)
			lnButtonWrite.Name = "ButtonWrite"
			lnButtonWrite.Size = System.Drawing.Size(75, 23)
			lnButtonWrite.TabIndex = 2
			lnButtonWrite.Text = "*�淶�ĵ�*"
			lnButtonWrite.UseVisualStyleBackColor = true
			if OutputFunction then
				lnButtonWrite.MouseClick:Add(OutputFunction)
			end
			
			-- ButtonComment �ؼ�
			lnButtonComment.Location = System.Drawing.Point(17, 533)
			lnButtonComment.Name = "ButtonComment"
			lnButtonComment.Size = System.Drawing.Size(75, 23)
			lnButtonComment.TabIndex = 3
			lnButtonComment.Text = "����ͷע��"
			lnButtonComment.UseVisualStyleBackColor = true
			if CommentFunction then
				lnButtonComment.MouseClick:Add(CommentFunction)
			end
			
			-- ButtonIndent �ؼ�
			lnButtonIndent.Location = System.Drawing.Point(98, 533)
			lnButtonIndent.Name = "ButtonIndent"
			lnButtonIndent.Size = System.Drawing.Size(75, 23)
			lnButtonIndent.TabIndex = 4
			lnButtonIndent.Text = "�Զ�����"
			lnButtonIndent.UseVisualStyleBackColor = true
			if IndentFunction then
				lnButtonIndent.MouseClick:Add(IndentFunction)
			end
			
			-- ������� TABLE
			tProtectedObj.__form = lnOutputForm
			-- ��ʾ����
			tProtectedObj.ShowDialog = function(self)
				--self.__form:ShowDialog()
				self.__form:Show()
			end
			tProtectedObj.SetLogsInfo = function(self, tLogs)
				local nTabControlIndex = self.__form.Controls:IndexOfKey("TabControl")
				local lnTabControl = self.__form.Controls[nTabControlIndex]
				local lntTabPages = {}
				local lntRichTextBoxs = {}

				-- ���� RTF ��ɫ
				local szRtfText = [[{\rtf1\ansi\ansicpg936\deff0\deflang1033\deflangfe2052{\fonttbl{\f0\fmodern\fprq6\fcharset134\'cb\'ce\'cc\'e5;}{\f1\fnil\fcharset134\'cb\'ce\'cc\'e5;}}]]
				local tColor = {
					black	= 1, {name = "black",	r =   0, g =   0, b =   0},
					red		= 2, {name = "red",		r = 196, g =  48, b =  48},
					green	= 3, {name = "green",	r =  48, g = 196, b =   0},
					blue	= 4, {name = "blue",	r =   0, g =   0, b = 255},
					gray	= 5, {name = "gray",	r = 196, g = 196, b = 196},
					yellow	= 6, {name = "yellow",	r = 196, g = 128, b =   0},
				}
				local szColorDefine = ""
				for i, v in pairs(tColor) do
					if type(v) == "table" then
						szColorDefine = szColorDefine .. "\\red" .. v.r .. "\\green" .. v.g .. "\\blue" .. v.b .. ";"
					end
				end
				szColorDefine = [[{\colortbl;]] .. szColorDefine .. [[}\viewkind4\uc1\pard\lang2052\f0\fs20 ]]
				
				local RtfFormat = function(szText)
					szText = szText:gsub("\n", "\\par\r\n")
					local TagConvert = function(szMatched)
						local szTextOrg = szMatched
						for k, v in pairs(tColor) do
							if type(v) ~= "table" then
								szMatched = szMatched:gsub("{" .. k .. "|", "\\cf" .. v)
								szMatched = szMatched:gsub("}", "\\cf0")
							end
						end
						return szMatched
					end
					szText = szText:gsub("%b{}", TagConvert)
					
					return szText
				end

				for i = 1, #tLogs do
					if type(tLogs[i]) == "string" then
						lntTabPages[i] = lnTabControl.Controls[lnTabControl.Controls:IndexOfKey("TabPage" .. i)]
						lntRichTextBoxs[i] = lntTabPages[i].Controls[lntTabPages[i].Controls:IndexOfKey("RichTextBox" .. i)]
						lntRichTextBoxs[i].Rtf = szRtfText .. szColorDefine .. RtfFormat(tLogs[i]) .. [[\cf0\f1\fs18\par}]]
					end
				end
			end
			
			return tProtectedObj
		end
	end
end

-- -------------------------
-- CUSTOM
-- -------------------------

-- ��ȡһ��tab�ļ�, �������tab�ļ������ݱ��浽һ����άTABLE��
-- > szFileName`	: �ļ���, �ļ�ǿ����ֻ��("r")ģʽ��, �������ڴ˴�д����
-- > szKeyName		: ������, ����������һ�ű���, ֵ���Բ��ظ����ֶ�
io.LoadTabFile = function(szFileName, szKeyName)
	szKeyName = szKeyName or "$NIL$"
	local tLinesData = {}							-- ����˳���ŵ�����
	local file = io.open(szFileName, "r")			-- ��Ĭ�ϵ�ֻ����ʽ���ļ�
	if not file then								-- �ļ���������ֱ�ӷ��ؿ�
		--io.MessageBox("û���ҵ��ļ�: " .. szFileName)
		return
	end
	local tMetaData = {								-- ������ Metatable �е�����
		Title = "",									-- �����ͷ
		Array = {},									-- ����Ϊ����
	}

	-- ���Զ�ȡ��ͷ�ַ���
	local szTableHeadLine = file:read("*line")			-- ��ȡ��һ�б�ͷ
	tMetaData.Title = szTableHeadLine:Split()			-- ����ͷ����Ĭ���зַ�("\t")�з�
	 
	-- ���波�Ա������ű�
	repeat
		local szLine = file:read("*line")				-- ˳���ȡÿһ��, read line ���Զ�ά��������, ÿ�ε��ö��Զ���ȡ��һ��
		if szLine then
			local tDatas = szLine:Split()				-- ��ÿһ�����ݲ��
			local tRowDatas = {}
			local szKeyValue = nil
			for i = 1, #tMetaData.Title do				-- ѭ��ÿ�е��ֶδ���
				tRowDatas[tMetaData.Title[i]] = tostring(tDatas[i])		-- ͳһ����Ϊ�ַ�������
				if tMetaData.Title[i]:lower() == szKeyName:lower() then	-- ����ҵ��� KEY, ���¼�� KEY ��ֵ
					szKeyValue = tDatas[i]
				end
			end
			
			table.insert(tMetaData.Array, tRowDatas)	-- ����˳�򱣴�����������
			if szKeyValue then
				local nID = tonumber(szKeyValue)
				if nID then
					tLinesData[nID] = tRowDatas
				else
					tLinesData[szKeyValue] = tRowDatas
				end
			end
		end
	until not szLine
	
	file:close()													-- �ر��ļ�
	setmetatable(tLinesData, tMetaData)								-- װ�� MetaData , �ⲿ�����ݲ�ֱ����Ϊ table ������
	return tLinesData
end

io.Trace = function(...)
	if ... then
		file = io.open("lualog.txt", "a+")
		file:write(... .. "\n")
		file:close()
	end
end

io.TraceInit = function()
	file = io.open("lualog.txt", "w")
	file:write(os.date() .. "\n\n")
	file:close()
end