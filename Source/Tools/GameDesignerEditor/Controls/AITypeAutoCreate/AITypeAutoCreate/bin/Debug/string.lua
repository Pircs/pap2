-- -------------------------
-- LUANET
-- -------------------------

-- ������ʽ

-- -------------------------
-- CUSTOM
-- -------------------------
-- ��һ���ַ������ո����ķָ����зֳ�һ�������������һ������
-- > szString	: ��Ҫ���и���ַ���
-- > szSpliter	: �и��, �����Ƕ���ַ���ɵ��ַ���, �� "@_@"
string.Split = function(szString, szSpliter)
	local tSplited = {}
	local nCount = 0								-- ��¼�ҵ����зַ�����
	local nStartLoc = 0								-- ��¼�������з��ַ����Ŀ�ʼ��
	local nEndLoc = 0								-- ��¼�������з��ַ����Ľ�����
	local bFoundSpliter = false						-- ��¼�Ƿ��ҵ��зַ�
	
	if not szSpliter then							-- ���û�д���ָ�����зַ�, ��Ĭ��Ϊ�Ʊ��tab
		szSpliter = "\t"
	end
	local szFormated = szString .. szSpliter		-- ��ʽ��ԭ�ַ���
	
	repeat
		nCount = nCount + 1
		bFoundSpliter, nEndLoc = szFormated:find(szSpliter, nStartLoc)
		if bFoundSpliter then
			tSplited[nCount] = szFormated:sub(nStartLoc, nEndLoc - #szSpliter)
			if not tSplited[nCount] then
				tSplited[nCount] = ""
			end
			nStartLoc = nEndLoc + 1
		end
	until not bFoundSpliter
	return tSplited
end

-- ȡ��һ���ļ�ȫ����·�����ļ���
string.SplitFileName = function(szFileName)
	if type(szFileName) ~= "string" then
		return
	end
	
	if not szFileName:find("\\") then
		return "", szFileName
	end
	return szFileName:match("(.*)\\(.*)$")
end

