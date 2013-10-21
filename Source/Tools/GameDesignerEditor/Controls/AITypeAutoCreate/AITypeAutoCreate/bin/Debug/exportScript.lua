 -- �������·���ǻ��� GameLuaEditor.exe ���ڵ�Ŀ¼
dofile("io.lua")	-- IO ������ STRING ͷ

-- -------------------------------------------------
-- ������һЩ���ߺ���
-- -------------------------------------------------

-- ����NPCTEMPLATE���ʱ��, ����ͬʱ������AITYPE��
-- NPCTEMPLATE���������⴦��, �Ὣ���ݿ�����ݷֳ������ֱַ𵼳�����������: NpcTemplate.tab AIType.tab

function ExportAIData(szTargetPath, mapInfo)
	-- ��ȡ����·��(�ͻ���λ��)
	local szFileFolder, szFileName = szTargetPath:SplitFileName()
	local szWorkFolder = szFileFolder:SplitFileName()
	
	-- �ϲ����е�AI������һ���ļ���, �����Զ��ж���Ҫʹ������AIģʽ
	local szAITypeTabFileName, szAITypeLuaFileName = CombineAITab(szWorkFolder, mapInfo)	
end

function GetMapNameList(szWorkFolder, mapInfo)
	local tMapNameList = {}

	for i = 1, mapInfo.Count do
		tMapNameList[i] = mapInfo[i - 1]
	end

	return tMapNameList
end

function CombineAITab(szWorkFolder, mapInfo)
	-- ȡ��������ر�� table	
	local tAITypeTab = io.LoadTabFile(szWorkFolder .. "\\settings\\AIType.tab", "AIType")
	local tAITypeCustomTab = io.LoadTabFile(szWorkFolder .. "\\settings\\AITypeCustom.tab", "AIType")		-- �Զ���AI
	local tAIPramTabs = {}
	local tSceneName = {}
	for nKey, szValue in pairs(GetMapNameList(szWorkFolder, mapInfo)) do
		tAIPramTabs[nKey] = io.LoadTabFile(szWorkFolder .. "\\settings\\map\\" .. szValue .. "\\NpcAIParameter\\NpcAIParameterList.tab", "ID")
		tSceneName[nKey] = szValue
		tSceneName[szValue] = szValue
	end
	
	-- ���潫������ر������ת��һ���ܱ���
	local tMainTabTitle = getmetatable(tAITypeTab).Title		-- ȡ������ͷ, ��AI�ܱ�Ϊ׼
	local szOutputTabName = szWorkFolder .. "\\settings\\AIType.tab"
	local fileTab = io.open(szOutputTabName, "w+")
	local szOutputLuaName = szWorkFolder .. "\\scripts\\ai\\AIParam.lua"
	local fileLua = io.open(szOutputLuaName, "w+")
	fileTab:write(table.concat(tMainTabTitle, "\t") .. "\n")
	fileLua:write("g_AIParam = {\n\n")

	-- ����ı�ͷ�϶��Ǹ�����, �������水�ձ�ͷ������˳��������֯ÿһ��, ������ԭ���˳���޹�
	-- ����AIType��
	
	if tAITypeTab then
		for i, v in ipairs(getmetatable(tAITypeTab).Array) do
			local szLine = {}
			v = IdentifyAIMode(v)
			for _, szField in ipairs(tMainTabTitle) do
				local szFieldValue = v[szField]
				if not szFieldValue then
					szFieldValue = ""
				end
				table.insert(szLine, szFieldValue)
			end
			
			if v.AIType and v.AIType ~= "0" then
				fileLua:write(Trans2LuaCode(szLine, tAITypeTab[0], tMainTabTitle))
				fileTab:write(table.concat(szLine, "\t") .. "\n")
			end
		end
	end
	
	-- ����AITypeCustom��
	if tAITypeCustomTab then
		for i, v in ipairs(getmetatable(tAITypeCustomTab).Array) do
			local szLine = {}
			v = IdentifyAIMode(v)
			for _, szField in ipairs(tMainTabTitle) do
				local szFieldValue = v[szField]
				if not szFieldValue then
					szFieldValue = ""
				end
				table.insert(szLine, szFieldValue)
			end
			
			if v.AIType and v.AIType ~= "0" then
				fileLua:write(Trans2LuaCode(szLine, tAITypeTab[0], tMainTabTitle))
				fileTab:write(table.concat(szLine, "\t") .. "\n")
			end
		end
	end
	
	-- �����������NpcAIParameterList��
	for _, tAISceneNpcTab in pairs(tAIPramTabs) do
		if tAISceneNpcTab then
			for i, v in ipairs(getmetatable(tAISceneNpcTab).Array) do
				local szLine = {}
				v = IdentifyAIMode(v)
		
				for _, szField in ipairs(tMainTabTitle) do
					local szFieldValue = v[szField]
					
					if szField:lower() == "aitype" then
						szFieldValue = v.ID
					end
					if not szFieldValue then
						szFieldValue = ""
					end

					table.insert(szLine, szFieldValue)
				end

				if v.ID and v.ID ~= "0" then
					fileLua:write(Trans2LuaCode(szLine, tAITypeTab[0], tMainTabTitle))
					fileTab:write(table.concat(szLine, "\t") .. "\n")
				end
			end
		end
	end
	
	fileLua:write("}")
	fileTab:close()	-- д�ļ�����
	fileLua:close()	-- д�ļ�����
	return szOutputTabName, szOutputLuaName
end

function IdentifyAIMode(tAIPrams)
	local tAIMode = {
		["scripts/ai/StandardAI.lua"] = true,
		["scripts/ai/idlepassive.lua"] = true,
		["scripts/ai/wanderpassive.lua"] = true,
		["scripts/ai/patrolpassive.lua"] = true,
		["scripts/ai/idleactive.lua"] = true,
		["scripts/ai/wanderactive.lua"] = true,
		["scripts/ai/patrolactive.lua"] = true,
	}
	
	-- ��������ͳһ��һ��LUA��, ������δ��뱣����������ת��
	tAIPrams.ScriptFile = tAIPrams.ScriptFile or ""
	
	if tAIPrams.ScriptFile == "" or tAIMode[tAIPrams.ScriptFile:lower():gsub("\\", "/")] then
		tAIPrams.ScriptFile = "scripts/ai/StandardAI.lua"
	end
	
	if not tAIPrams.NpcSceneType or tAIPrams.NpcSceneType == "" then
		tAIPrams.NpcSceneType = "0"
	end
	if tAIPrams.NpcSceneType == "1" and tAIPrams.ScriptFile == "scripts/ai/StandardAI.lua" then
		tAIPrams.ScriptFile = "scripts/ai/DungeonStandardAI.lua"
	elseif tAIPrams.NpcSceneType == "0" and tAIPrams.ScriptFile == "scripts/ai/DungeonStandardAI.lua" then
		tAIPrams.ScriptFile = "scripts/ai/StandardAI.lua"
	end

	return tAIPrams
end

function Trans2LuaCode(tAIPrams, tDefaultAIPrams, tTitle)
	local tIgnoreList = {
		Name 			= "Name",				-- �г��˲���Ҫ������ֶ�����
		ID				= "ID",
		MainState		= "MainState",
		PursuitRange	= "PursuitRange",
		ScriptName		= "ScriptName",
		AIType			= "AIType",
		CustomArguments	= "CustomArguments",	-- AI����ͼ�õ��Ŀɱ�������б�, �����Ⱥ���, ��������������
		ScriptFile		= "ScriptFile",			-- ����������浼��, ������ר��ģ��������
	}
	local szCodeLine = ""
	local FormatValue = function(value)
		if tonumber(value) then
			value = tonumber(value)
		elseif type(value) == "string" then
			value = "\"" .. value .. "\""
		elseif type(value) == "nil" then
			value = ""
		end
		return value
	end
	
	local nCustomArgsIndex = nil
	local nAINameIndex = nil
	local tTitleMap = {}
	for nIndex, szKey in ipairs(tTitle) do
		tTitleMap[szKey] = true
		if not tIgnoreList[szKey] then			-- ��֤�����б���
			if tAIPrams[nIndex] == "" then
				if tDefaultAIPrams[szKey] and tDefaultAIPrams[szKey] ~= "" then
					szCodeLine = szCodeLine .. szKey .. " = " .. FormatValue(tDefaultAIPrams[szKey]) .. ", "
				end
			else
				szCodeLine = szCodeLine .. szKey .. " = " .. FormatValue(tAIPrams[nIndex]) .. ", "
			end
		end
		if szKey == "CustomArguments" then
			nCustomArgsIndex = nIndex
		elseif szKey == "ScriptFile" then
			nAINameIndex = nIndex
		end
	end	

	szCodeLine = "\t\[" .. tAIPrams[1] .. "\]\t= {" .. szCodeLine .. "},\n"
	return szCodeLine
end

