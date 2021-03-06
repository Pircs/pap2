/************************************************************************/
/* 道具			                                                        */
/* Copyright : Kingsoft 2005										    */
/* Author	 : Zhu Jianqiu												*/
/* History	 :															*/
/*		2004.12.31	Create												*/
/************************************************************************/
#ifndef _KITEM_H_
#define _KITEM_H_

#include "Global.h"
#include "KBaseObject.h"
#include "KAttribute.h"
#include "KItemInfoList.h"
#include "Luna.h"
#include "KEnchantLib.h"
#include "KItemDef.h"

struct COMMON_ATTRIBUTE
{
	char				szItemName[ITEM_NAME_LEN];	// 名称
	int					nLevel;						// 等级
	int					nPrice;						// 价格
	int					nGenre;						// 大类
	int					nSub;						// 小类
	int					nDetail;					// 细类
	BOOL				bCanTrade;					// 是否可买卖
	BOOL				bCanDestroy;				// 是否可摧毁	TODO： --spe
    int					nMaxExistAmount;			// 最大存在数量

	BOOL				bConsumeDurabiltity;		// 是否消耗耐久
	BOOL				bStack;						// 是否能够叠放
	int					nBindType;					// 绑定类型
	int					nAbradeRate;				// 被磨损机率
	DWORD				dwSetID;					// 套装号
};

struct GENERATE_PARAM
{
	DWORD				dwTabType;
	DWORD				dwIndex;
	time_t				nGenTime;
	DWORD				dwRandSeed;
	int					nQuality;					// 道具品质 (普通? 黄金? )
};

class KItem : public KBaseObject
{
public:
	KItem();
	~KItem();

	BOOL Init();
	void UnInit();

    KItemInfo*          m_pItemInfo;

	GENERATE_PARAM		m_GenParam;				// 生成需要的参数
	COMMON_ATTRIBUTE	m_Common;				// 一般属性
	DWORD				m_dwSkillID;			// 技能ID
	DWORD				m_dwSkillLevel;			// 技能等级

	KAttribute*			m_pBaseAttr;			// 基础属性
	KAttribute*			m_pRequireAttr;			// 需求属性
	KAttribute*			m_pMagicAttr;			// 魔法属性

	
	time_t				m_nEnchantTime;         // 限时附魔结束时间

	DWORD				m_dwScriptID;			// 脚本ID
    DWORD               m_dwEnchantID[eiTotal];
	union
	{
		int				m_nCurrentDurability;	// 当前耐久度
		int				m_nStackNum;			// 当前叠加数量
	};
	union
	{
		int				m_nMaxDurability;		// 最大耐久度(某些装备，此值会动态变化)
		int				m_nMaxStackNum;			// 最大叠加上限
		int				m_nPackageSize;			// 背包格子数量
	};

	BOOL				m_bBind;				// 是否被绑定
	int					m_nRepresentID;			// 表现逻辑ID
    int                 m_nColorID;             // 偏色id
	BOOL				m_bApplyed;				// 是否已应用属性
	BOOL				m_bEquiped;				// 是否已经装备

#if defined(_CLIENT)
	int					m_nUiId;				// 界面ID
#endif	//_CLIENT

public:
	BOOL				SetStackNum(int nStackNum);
	int					GetStackNum();
	int					GetMaxStackNum();
	int					GetMaxExistAmount();				// 获取物品的数量限制,0是无限制
	int					Stack(int nCount);
    BOOL                SetCurrentDurability(int nDurability);
    int                 GetCurrentDurability();
    int                 GetMaxDurability();
	int					GetGenre() { return m_Common.nGenre; };
	int					GetPrice() { return m_Common.nPrice; };
	BOOL				IsBind() { return m_bBind; };
	BOOL				IsStackable();
	BOOL				IsRepairable();
	BOOL				IsCanTrade() { return m_Common.bCanTrade; };
	BOOL				IsCanDestroy() { return m_Common.bCanDestroy; };
	BOOL				CanStack(KItem* pDest);
	BOOL				Repair();
	BOOL				Abrade();

    BOOL                GetBinaryData(size_t* puUsedSize, BYTE* pbyBuffer, size_t uBufferSize);
#ifdef _SERVER
    BOOL                ResetCoolDown(KPlayer* pPlayer);
#endif
    int                 GetRequireLevel();
    KItemInfo*          GetItemInfo();
    int                 GetMountIndex();

    // 临时代码, 等UI脚本改好了再去掉这个
    int getVersion(void) {return 1;}
	void setVersion(int nValue)	{}

private:
    BOOL                HaveDurability();
public:
	//Lua脚本接口
	DECLARE_LUA_CLASS(KItem);

	DECLARE_LUA_STRUCT_STRING(Name, ITEM_NAME_LEN, m_Common.szItemName);
	DECLARE_LUA_STRUCT_INTEGER(Level, m_Common.nLevel);
	DECLARE_LUA_STRUCT_INTEGER(Price, m_Common.nPrice);
	DECLARE_LUA_STRUCT_INTEGER(Genre, m_Common.nGenre);
	DECLARE_LUA_STRUCT_INTEGER(Sub, m_Common.nSub);
	DECLARE_LUA_STRUCT_INTEGER(Detail, m_Common.nDetail);
	DECLARE_LUA_STRUCT_INTEGER(BindType, m_Common.nBindType);
	DECLARE_LUA_STRUCT_BOOL(CanTrade, m_Common.bCanTrade);
	DECLARE_LUA_STRUCT_BOOL(CanDestroy, m_Common.bCanDestroy);
	DECLARE_LUA_STRUCT_BOOL(CanStack, m_Common.bStack);
	DECLARE_LUA_STRUCT_BOOL(CanConsume, m_Common.bConsumeDurabiltity);
	DECLARE_LUA_STRUCT_DWORD(SetID, m_Common.dwSetID);
	DECLARE_LUA_STRUCT_DWORD(TabType, m_GenParam.dwTabType);
	DECLARE_LUA_STRUCT_DWORD(Index, m_GenParam.dwIndex);
    DECLARE_LUA_STRUCT_TIME(GenTime, m_GenParam.nGenTime);
	DECLARE_LUA_STRUCT_INTEGER(MaxExistAmount, m_Common.nMaxExistAmount);
	DECLARE_LUA_STRUCT_INTEGER(Quality, m_GenParam.nQuality)

	DECLARE_LUA_INTEGER(CurrentDurability);
	DECLARE_LUA_INTEGER(StackNum);
	DECLARE_LUA_INTEGER(MaxDurability);
	DECLARE_LUA_INTEGER(MaxStackNum);

	DECLARE_LUA_BOOL(Bind);
	DECLARE_LUA_INTEGER(RepresentID);
    DECLARE_LUA_INTEGER(ColorID);

#ifdef _CLIENT
	DECLARE_LUA_INTEGER(UiId);

	int LuaGetBaseAttrib(Lua_State* L);
	int LuaGetRequireAttrib(Lua_State* L);
	int LuaGetMagicAttrib(Lua_State* L);
	int LuaGetPermanentEnchantAttrib(Lua_State* L);
	int LuaGetTemporaryEnchantAttrib(Lua_State* L);
    int LuaGetMountAttrib(Lua_State* L);
	int	LuaGetSetAttrib(Lua_State* L);
	int LuaCanEquip(Lua_State* L);
    int LuaGetMountItemUIID(Lua_State* L);
    int LuaIsDestroyOnMount(Lua_State* L);

#endif	//_CLIENT
    int LuaIsRepairable(Lua_State* L);

	int LuaGetUseSkill(Lua_State* L);
	int LuaHasScript(Lua_State* L);
    int LuaGetRequireLevel(Lua_State* L);
    int LuaGetTemporaryEnchantLeftSeconds(Lua_State* L);
    int LuaGetMountIndex(Lua_State* L);
    int LuaGetLeftExistTime(Lua_State* L);
};

#endif	//_KITEM_H_
