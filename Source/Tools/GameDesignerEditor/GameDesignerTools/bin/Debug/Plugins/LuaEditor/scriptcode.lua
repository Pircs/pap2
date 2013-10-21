Type = luanet.System.Type
GetType = lt_GetType --luanet.System.Type.GetType
Forms = luanet.System.Windows.Forms
tracebox = Forms.MessageBox.Show

luanet.load_assembly('ScriptViewer.dll')
luaEditor = luanet.luaEditor
leParm = luaEditor.leParm
leEvent = luaEditor.leEvent
leParmsCache = luaEditor.leParmsCache
leTableItem = luaEditor.leTableItem
regEvent = leParmsCache.regEvent

--�����¼�
local function handle_queryEvents(sender, e)
    regEvent(e,
           'ongettreevalue',
           '�����Զ�����������ʾ���� ����ʱ����ÿ���������ʾ����ʱ������ô˺��������˺������طǿ�ֵʱ��������ֵ��Ϊ��������ʾ',
           leParm('prop', GetType('GameDesingerTools.CustomProperty'), 'ongettreevalue'),
           leParm('e', GetType('GameDesingerTools.TreeValueEventArgs'), 'ongettreevalue')
           )
    
    regEvent(e,
            'onselectrecordchanged',
            '�л�����ͬ��¼��',
            leParm('properties', GetType('GameDesingerTools.DBCustomClass'), 'onselectrecordchanged'),
            leParm('selecttabindex', GetType('System.Int'), 'onselectrecordchanged')
            )
    

    regEvent(e,
            'onaftervaluechanged',
            '���Ըı��',
            leParm('prop', GetType('GameDesingerTools.CustomProperty'), 'onaftervaluechanged'),
            leParm('e', GetType('GameDesingerTools.PropertyAfterChangeEventArgs'), 'onaftervaluechanged')
            )

    regEvent(e,
            'onbeforevaluechang',
            '���Ըı��',
            leParm('prop', GetType('GameDesingerTools.CustomProperty'), 'onbeforevaluechang'),
            leParm('e', GetType('GameDesingerTools.PropertyChangeEventArgs'), 'onbeforevaluechang')
            )

    regEvent(e,
            'oneditvalue',
            '�Զ���ı༭��ʽ',
            leParm('prop', GetType('GameDesingerTools.CustomProperty'), 'oneditvalue'),
            leParm('e', GetType('GameDesingerTools.CustomEditorEventArgs'), 'oneditvalue')
            )

    regEvent(e,
            'onnewrecord',
            '���ӱ��¼',
            leParm('prop', GetType('GameDesingerTools.CustomProperty'), 'onnewrecord'),
            leParm('svalue', GetType('System.String'), 'onnewrecord'),
            leParm('kv', GetType('GameDesingerTools.NewRowKeyValueHelper'), 'onnewrecord'),
            leParm('id', GetType('System.String'), 'onnewrecord')
            )

    regEvent(e,
            'onselectpropertychanged',
            '�л�����ͬ�ֶκ�',
            leParm('prop', GetType('GameDesingerTools.CustomProperty'), 'onselectpropertychanged')
            )
end

--�������
local function handle_queryObjects(sender, e)
    local _lt = lt2ArrayList(p_lua, e.keyword)
    local ind
    local v,k
    for ind = 0, _lt.Count - 1 do
        k = _lt[ind][0]
        v = _lt[ind][1]
        if v == 'table' or v == 'function' then
		e.leTable:Add(k, leTableItem(k, v, v, v))   
        end         
    end
end

--�������
local function handle_queryParms(sender, e)
	local ret = lt2ArrayList_parms(p_lua, e.keyword)
    if ret ~= nil and ret ~= '' then
        e.parms_list:Add(ret);   
    end     
end

local function regOneFunction(obj, name)
    obj:regObject(name, nil, GetType('GameDesingerTools.BaseForm'):GetMethod(name), '')
    obj:regObject(name .. '()', GetType('GameDesingerTools.BaseForm'):GetMethod(name).ReturnType, GetType('GameDesingerTools.BaseForm'):GetMethod(name), '')
end

--ע��ȫ�ֱ���
local function regGlobalObjects(obj)
    obj:regObject('BaseForm', GetType('GameDesingerTools.BaseForm'), nil, '')
    obj:regObject('TblMain', GetType('System.Data.DataTable'), nil, '');
    obj:regObject('Pages', GetType('System.Collections.ArrayList'), nil, '');
    obj:regObject('BaseTree', GetType('System.Windows.Forms.TreeView'), nil, '');
    obj:regObject('Form', GetType('GameDesingerTools.BaseForm'), nil, '');
    obj:regObject('Conn', GetType('System.String'), nil, '');
    obj:regObject('RootDir', GetType('System.String'), nil, '');
    obj:regObject('StartUpDir', GetType('System.String'), nil, '');

    regOneFunction(obj, 'FindTreeNode')
    regOneFunction(obj, 'AddTreeNodes')
    regOneFunction(obj, 'AddTreeNodeClone')
    regOneFunction(obj, 'RemoveTreeNode')
    regOneFunction(obj, 'ExpandTreeNode')
    regOneFunction(obj, 'MoveTreeNode')
    regOneFunction(obj, 'SqlQueryOnce')
    regOneFunction(obj, 'SqlInsertRecord')
    regOneFunction(obj, 'SqlUpdateRecord')
    regOneFunction(obj, 'SqlUpdateRecords')
    regOneFunction(obj, 'SqlRemoveRecord')
    regOneFunction(obj, 'SqlRemoveRecords')
    regOneFunction(obj, 'FindRowInTable')
    regOneFunction(obj, 'ObjToObjArr')
    regOneFunction(obj, 'ObjToObjArr2')
    regOneFunction(obj, 'FindAllTreeNodesByLevel')
    regOneFunction(obj, 'InitPgAndPghelper')
    regOneFunction(obj, 'SelectTreeNode')
    regOneFunction(obj, 'GetPropDefaultValue')
    regOneFunction(obj, 'DataBaseNull')
    regOneFunction(obj, 'GetUnusedID')
    regOneFunction(obj, 'RegComDll')
    regOneFunction(obj, 'ConvertToInt32')
    regOneFunction(obj, 'InitPreview')
    regOneFunction(obj, 'InitPreviewPlugIn')
    regOneFunction(obj, 'LoadModel')
    regOneFunction(obj, 'BeginEdit')

    obj:regObject('OpenForm', nil, GetType('GameDesingerTools.MainForm'):GetMethod('OpenForm'), '')
    obj:regObject('OpenForm' .. '()', GetType('GameDesingerTools.MainForm'):GetMethod('OpenForm').ReturnType, GetType('GameDesingerTools.MainForm'):GetMethod('OpenForm'), '')
end

--ע������
local function regEditorControl(sender, e)
	ctl_ce = e.luace
	ctl_ce.queryEvents:Add(handle_queryEvents)
	ctl_ce.queryObjects:Add(handle_queryObjects)
	ctl_ce.queryParms:Add(handle_queryParms)
	regGlobalObjects(ctl_ce)
end

--����ű����ڴ沢ִ��
local function fsv_OnWindowSave(sender, e)
	local fieldid = e.fieldid
	local tabid = e.tabid
	local strret = ""
	if fieldid ~= nil and tabid ~= nil then
		strret = SaveScriptIntoDatabase(fieldid, tabid, e.strcode)
	end
	if strret == "NG" then
		tracebox("����ʧ��")
	else
		if e.tag ~= nil then
			local logscript = e.tag["logscript"]
			logscript:Log(e.tag["modify_1"],e.tag["modify_2"],e.tag["modify_3"],e.tag["modify_4"])
		end
	end
end

--�������̵���
function OpenWindow(field, modtabid)
	--tracebox("field:" .. field .. " modtabid:" .. modtabid)
	if fsv == nil then
		fsv = luanet.ScriptViewer.frmScriptView(Conn)
		fsv.OnNewWindow:Add(regEditorControl)
		fsv.OnWindowSave:Add(fsv_OnWindowSave)
	end
	fsv:OpenWindow(field, modtabid, tag)
	fsv:Show()
end

function OpenFileWindow(strfile)
	--tracebox("field:" .. field .. " modtabid:" .. modtabid)
	if fsv == nil then
		fsv = luanet.ScriptViewer.frmScriptView(Conn)
		fsv.OnNewWindow:Add(regEditorControl)
		fsv.OnWindowSave:Add(fsv_OnWindowSave)
	end
	fsv:OpenFileWindow(strfile, tag)
	fsv:Show()
end
