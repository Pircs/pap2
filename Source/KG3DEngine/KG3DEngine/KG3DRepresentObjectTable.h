#pragma once

#include "../../../Include/kg3dengine/kg3dinterface.h"
#include "KG3DTemplates.h"
#include "KG3DRepresentObject.h"

typedef KG3DRepresentObject* (*TypeFuncRepresentObjBuilder)(DWORD_PTR wParam, DWORD_PTR lParam);

class KG3DRepresentObjectTable :
	public TKG3DResourceManagerBase<KG3DRepresentObject>
{
private:
	typedef TKG3DResourceManagerBase<KG3DRepresentObject> TypeBaseClass;
	std::vector<TypeFuncRepresentObjBuilder>	m_vecBuilder;//����������Vec
public:
    // ��ʼ��,�������
    //virtual HRESULT Init();
    //virtual HRESULT UnInit();
    
    // ��Դ����
    //virtual HRESULT LoadResourceFromFile(
    //    IKG3DResourceBase** ppResource, LPSTR pFileName
    //);
    //virtual HRESULT Get1NewResourse(
    //    IKG3DResourceBase** ppResource, DWORD dwType
    //);
    //virtual HRESULT GetResourse(
    //    IKG3DResourceBase** ppResource, DWORD dwID
    //);

    virtual HRESULT Get1NewResourcePointer(KG3DRepresentObject** ppT,DWORD Type,DWORD_PTR);
	virtual HRESULT Init();

	HRESULT GetCopy(KG3DRepresentObject** ppOut,KG3DRepresentObject* pIn);
	HRESULT GetTypeInfoByFileName(TypeInfo** ppTypeInfo, const char cszFileName[]){return TypeBaseClass::GetTypeInfoByFileName(ppTypeInfo, cszFileName);}//��¶�������Ϊpublic
	
	//ע��ͷ�ע�ᴴ������
	HRESULT RegisterType(DWORD dwType, TypeFuncRepresentObjBuilder Builder);
	HRESULT UnRegisterType(DWORD dwType, TypeFuncRepresentObjBuilder* pTheUnregisteredBuilder);

public:
	KG3DRepresentObjectTable(void);
	virtual ~KG3DRepresentObjectTable(void);
};

extern KG3DRepresentObjectTable& g_GetObjectTable();//�ĳ��������Ա�������ʼ��˳�������