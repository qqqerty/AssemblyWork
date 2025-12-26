.386
.model flat, stdcall
option casemap:none

include				windows.inc
include				user32.inc
includelib			user32.lib
include				kernel32.inc
includelib			kernel32.lib
include				Gdi32.inc
includelib			Gdi32.lib
includelib			msvcrt.lib
include				shell32.inc
includelib			shell32.lib
include				comctl32.inc
includelib			comctl32.lib
include				masm32.inc
includelib			masm32.lib
includelib			gdiplus.lib
include				gdiplus.inc


printf				PROTO C:dword, :vararg
srand				PROTO C:dword, :vararg
rand				PROTO C:vararg
memset				PROTO C:dword, :dword, :dword, :vararg
sprintf				PROTO C:dword, :dword, :dword, :vararg

;定义需要用到的id
IDI_ICON			equ				201
ID_TIMER			equ				1
ID_UP				equ				101
ID_DOWN				equ				102
ID_LEFT				equ				103
ID_RIGHT			equ				104
ID_STOP				equ				100
ID_SCORE			equ				105
ID_MODULESTARTER	equ				106
ID_MODULESIMPLE		equ				107
ID_MODULEADVANCED	equ				108
ID_MODULEHARD		equ				109
ID_MODULESHOW		equ				110
ID_SpeedShow		equ				111
ID_CharacterShow    equ             112
ID_SKILL            equ             113
ID_COOLDOWN         equ             114
ID_NewGame			equ				98
ID_SetModule		equ				97
ID_HELP				equ				96
ID_About			equ				95
ID_Continue			equ				94
ID_Character1        equ             91
ID_Character2        equ             92
ID_Character3        equ             93
LF					equ				0ah



.data
hInstance			dd				?
hWinMain			dd				?
dwX					dd				500		dup(0);存储蛇的坐标左上角
dwY					dd				500		dup(0)
dwXT				dd				500		dup(0);用于存储坐标右下角
dwYT				dd				500		dup(0)
printBuffer			byte			10		dup(0)
dwNextX				dd				?
dwNextY				dd				?
dwXTemp				dd				?			;临时
dwYTemp				dd				?			;临时		
dwSnakeLen			dd				?			;蛇的长度
dwExtraScore        dd              0           ;由技能导致的额外分
dwSnakeSize			dd				10			;蛇大小,需要设置蛇大小为步长的一半才能实现头部碰到东西即可吃下
dwStep				dd				20			;步长，即每次移动的距离
dwTime				dd				300			;刷新时间间隔
dwDirection			dd				?			;1表示上，2表示下，3表示左，4表示右，0表示停止
dwDirectionTemp		dd				0			;用于临时保存移动方向
dwRandX				dd				?			;保存随机产生的坐标
dwRandY				dd				?			
dwModuleflag		dd				1			;表示选择的模式，0、1、2、3分别代表入门、简单、进阶、困难模式
dwCharacterflag     dd              1           ;表示选择的角色
Num					byte			"%d", 0		;输出数字
Blank				byte			" ", 0		;输出空格
Line				byte			0ah, 0		;用于输出空行
szButton			byte			"button", 0
szButton_Stop		byte			"暂停", 0
szButton_Restart	byte			"重玩", 0
hButton				dd				?
ButtonFlag			dd				0			;0表示停止，1表示运动，2表示重玩
szStatic			byte			"static", 0
szEdit				byte			"edit", 0
dwSCORE				db				"分数:", 0
dwSPEED				byte			"速度:", 0
dwCHARACTER         byte            "角色:",0
dwCOOLDOWN          byte            "C D:",0
hScore				dd				?
dwCoolDown          dd              0           ;冷却时间
dwSkillUsed         dd              0       ; 技能是否已使用（0=未使用，1=已使用）
TP_used             dd              0        ;TP被使用的标志
szBoxTitle			db				"游戏提示", 0
szBoxText			db				"你死了！", 0
dwMODULE			db				"难度:", 0
dwMODULESET			byte			'难度选择', 0
dwMODULESTARTER		byte			'入门', 0
dwMODULESIMPLE		byte			'简单', 0
dwMODULEADVANCED	byte			'进阶', 0
dwMODULEHARD		byte			'困难', 0
dwCharacterSET      byte            '选择角色', 0
dwCHARACTER1        byte            '分裂蛇',0
dwCHARACTER2        byte            '无头蛇',0
dwCHARACTER3        byte            '虫洞蛇',0
dwTempX             dd              0       ; 临时存储坐标,技能2反转用
dwTempY             dd              0
lastX               dd              0
lastY               dd              0

;wk 障碍物相关
barrierX 			dd				500 	dup(0)
barrierY 			dd				500		dup(0)
barrierXT			dd				500		dup(0)
barrierYT			dd				500 	dup(0)
barrierNum			dd				?
numbe				byte			"%d", 0ah, 0	
hBarrierPen 		HPEN			?

;字体相关
hFont_small			HFONT			?
hFont_big			HFONT			?
hFont_Show			HFONT			?
hFont_digit			HFONT			?
szYaHei				byte			'微软雅黑', 0
szShuTi				byte			'方正舒体', 0
szMVBoli			byte			'MV Boli', 0
szKaiTi              byte            'KaiTi',0           ; 楷体



;画刷画笔句柄
hWhiteBrush			HBRUSH			?
hGameBackgroundBrush HBRUSH			?	; 游戏背景的画刷
hBorderPen			HPEN			?
hBorderBrush        HBRUSH          ?
hSnakeHeadPen		HPEN			?
hSnakeBodyPen		HPEN			?
hFoodPen			HPEN			?
hSnakeHeadPen1    HPEN            ?
hSnakeBodyPen1    HPEN            ?
hSnakeHeadPen2    HPEN            ?
hSnakeBodyPen2    HPEN            ?
hSnakeHeadPen3    HPEN            ?
hSnakeBodyPen3    HPEN            ?

; GDI+相关变量
gdiplusToken       dd              ?
pImage             dd              ?          ; 指向GDI+图像的指针
; 图片路径
szMenuBackground   db       'menu_bg.png', 0
wzMenuBackground   dw          200 dup(?)                ; 宽字符缓冲区（MAX_PATH = 200）


;控制当前显示页面的flag
menuFlag			byte			0	;0:开始菜单;1:游戏界面;2:选择角色;3:设置难度
;控制是否有"继续"按钮的flag
continueBtnFlag		byte			0

.const
szClassName			db				'貪喫蛇', 0
szSetModule			byte			'选择难度', 0
szHelp				byte			'操作说明', 0
szAbout				byte			'技能介绍', 0
szNewGame			byte			'新游戏', 0
szContinue			byte			'继续', 0
szHelpText			byte			'使用W、A、S、D或↑、↓、←、→键分别控制贪吃蛇向上下左右转向，Q释放技能，以吃到绿色的食物增长身体并获得分数。', LF, LF
szHelpText2			byte			'模式说明:', LF,
									'入门: 速度很慢', LF,
									'简单: 速度一般', LF,
									'↑这是默认的模式', LF,
									'进阶: 速度越来越快', LF,
									'困难: 速度非常快', 0
szAboutText			byte			'分裂蛇：使用后长度减半，长度越长cd越长', LF,
									'无头蛇：使用后头和尾巴交换，开始反方向运动,cd: 5', LF,
									'虫洞蛇：从头到尾逐渐传送回出生点,cd: 5', 0
.code
;***************************************************************************************
;
;随机数生成函数
;
;***************************************************************************************
_Rand				proc	   ;生成随机坐标 randX,randY
					
					local @stTime:SYSTEMTIME
					invoke GetLocalTime, addr @stTime
					movzx eax, @stTime.wMilliseconds
					invoke srand, eax					;更新种子
					invoke rand
					mov ebx, 19
					div ebx
					imul edx, dwStep
					add edx, 35
					mov dwRandX, edx

					movzx eax, @stTime.wMilliseconds
					invoke rand
					mov ebx, 19
					div ebx
					imul edx, dwStep
					add edx, 35
					mov dwRandY, edx
					
					ret
_Rand				endp


;***************************************************************************************
;
;初始化函数，用于初始化寄存器的值及画笔画刷对象。
;
;***************************************************************************************
_Init				proc
					;将保存坐标的两个数组全部初始化为0
					invoke			memset, addr dwX, 0, sizeof dwX
					invoke			memset, addr dwY, 0, sizeof dwY
					invoke			memset, addr dwXT, 0, sizeof dwXT
					invoke			memset, addr dwYT, 0, sizeof dwYT
				;	 mov          menuFlag, 0
					;初始第一个点dwX[0] and dwY[0] (215,35)
					mov eax, 215
					mov ebx, 0
					mov dwX[ebx], eax
					add eax, dwSnakeSize
					mov dwXT[ebx], eax
					mov eax, 35
					mov ebx, 0
					mov dwY[ebx], eax
					add eax, dwSnakeSize
					mov dwYT[ebx], eax

					;初始化第一个猎物的位置
					invoke _Rand
					mov eax, dwRandX
					mov dwNextX, eax
					mov eax, dwRandY
					mov dwNextY, eax

					;初始化蛇长度
					mov dwSnakeLen, 1
					mov dwExtraScore, 0
					;初始化cd
					mov dwCoolDown, 0
					mov TP_used, 0
					;初始化方向
					mov dwDirection, 2

					;wk,障碍物初始个数为 8
					mov				barrierNum, 8
					;障碍物位置初始化
					mov esi, 0
					.repeat
						;push esi
						;invoke _sleep
						;invoke _Rand
						.repeat
							push esi
							invoke rand
							pop esi
							mov ebx, 19
							div ebx
							imul edx, dwStep
							add edx, 35
						.until edx != dwNextX && edx != dwX[0]  ;不与蛇头重合
						mov eax, edx
						mov barrierX[esi], eax
						add eax, dwSnakeSize
						mov barrierXT[esi], eax

						.repeat
							push esi
							invoke rand
							pop esi
							mov ebx, 19
							div ebx
							imul edx, dwStep
							add edx, 35
						.until edx != dwNextY && edx != dwY[0]
						mov eax, edx
						mov barrierY[esi], eax
						add eax, dwSnakeSize
						mov barrierYT[esi], eax
						invoke printf, offset numbe, eax
						add esi, 4
						mov ebx, barrierNum
						imul ebx, 4
					.until esi == ebx

					ret
_Init				endp

;***************************************************************************************
;
;设置字体
;
;***************************************************************************************
_createFont			proc
					invoke  CreateFont,
								-16, 
								-8,
								0, 0, 
								400,
								FALSE, FALSE, FALSE,
								DEFAULT_CHARSET,
								OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS,
								DEFAULT_QUALITY,
								FF_DONTCARE,
								offset szYaHei
					mov     hFont_small, eax   
					invoke  CreateFont,
								-48, 
								-24,
								0, 0, 
								FW_BOLD,
								FALSE, FALSE, FALSE,
								DEFAULT_CHARSET,
								OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS,
								DEFAULT_QUALITY,
								FF_DONTCARE,
								offset szShuTi
					mov     hFont_big, eax  
					invoke  CreateFont,
								-24, 
								-12,
								0, 0, 
								FW_BOLD,
								FALSE, FALSE, FALSE,
								DEFAULT_CHARSET,
								OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS,
								DEFAULT_QUALITY,
								FF_DONTCARE,
								offset szKaiTi
					mov     hFont_Show, eax  
					invoke  CreateFont,
								-30, 
								-15,
								0, 0, 
								FW_BOLD,
								FALSE, FALSE, FALSE,
								DEFAULT_CHARSET,
								OUT_CHARACTER_PRECIS, CLIP_CHARACTER_PRECIS,
								DEFAULT_QUALITY,
								FF_DONTCARE,
								offset szMVBoli
							  ;  offset szArial 
					mov     hFont_digit, eax  

					ret
_createFont			endp

;***************************************************************************************
;
;设置画刷画笔
;
;***************************************************************************************
_createPens			proc
					;初始化背景画刷
					mov				eax, 0ffffffh		
					invoke			CreateSolidBrush, eax
					mov				hWhiteBrush, eax
					;游戏背景画刷
					mov				eax, 0fffff0h
					invoke			CreateSolidBrush, eax
					mov				hGameBackgroundBrush, eax
					;游戏边框画笔
					mov				eax, 07AA0FFh	;BGR
					invoke			CreatePen, PS_SOLID, 3, eax
					mov				hBorderPen, eax

					;游戏边框画刷
					mov				eax, 07AA0FFh		
					invoke			CreateSolidBrush, eax
					mov				hBorderBrush, eax

					;蛇头蛇身画笔
					mov				eax, 0F7CC25h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hSnakeHeadPen, eax
					mov				eax, 0FC9C1Bh
					; mov				eax, 0ffh + 0d3h * 100h + 01h * 10000h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hSnakeBodyPen, eax

					
                   ; 角色1：暗红色（分裂蛇）
                         mov    eax, 5555CDh      ; 暗红色 BGR
                         invoke CreatePen, PS_SOLID, dwSnakeSize, eax
                         mov    hSnakeHeadPen1, eax
                         mov    eax, 6A6AFFh      ; 稍亮的暗红色
                         invoke CreatePen, PS_SOLID, dwSnakeSize, eax
                         mov    hSnakeBodyPen1, eax
    
                    ; 角色2：当前颜色（无头蛇）- 蓝色
                      mov    eax, 0FC9C1Bh       
                      invoke CreatePen, PS_SOLID, dwSnakeSize, eax
                      mov    hSnakeHeadPen2, eax
                      mov    eax,0FFBF00h    
                      invoke CreatePen, PS_SOLID, dwSnakeSize, eax
                       mov    hSnakeBodyPen2, eax
    
                      ; 角色3：紫色（虫洞蛇）
                      mov    eax, 800080h      ; 紫色 BGR
                      invoke CreatePen, PS_SOLID, dwSnakeSize, eax
                      mov    hSnakeHeadPen3, eax
                      mov    eax, 9370DBh      ; 中紫色
                      invoke CreatePen, PS_SOLID, dwSnakeSize, eax
                      mov    hSnakeBodyPen3, eax
    
   
 
					;猎物画笔
					mov				eax, 90C732h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hFoodPen, eax
					;wk 障碍物画笔
					mov				eax, 666666h
					invoke			CreatePen, PS_SOLID, dwSnakeSize, eax
					mov				hBarrierPen, eax
				

					ret
_createPens			endp


;***************************************************************************************
;
;画线函数，从(x1, y1)画线到(x2, y2)
;
;***************************************************************************************
_DrawLine			proc			_hDC, X1, Y1, X2, Y2
					invoke			MoveToEx, _hDC, X1, Y1, NULL
					invoke			LineTo, _hDC, X2, Y2
					ret
_DrawLine			endp

;***************************************************************************************
;
;角色2反转函数
;
;***************************************************************************************
_ReverseSnakeBody proc
    mov dwDirection, 0
    ; 反转蛇身所有节的顺序
    mov esi, 0                   ; 起始索引
    mov edi, dwSnakeLen
    dec edi                      ; 尾部索引
    imul edi, 4
    
    .while esi < edi
        ; 交换 dwX[esi] 和 dwX[edi]
        mov eax, dwX[esi]
        mov ebx, dwX[edi]
        mov dwX[esi], ebx
        mov dwX[edi], eax
        
        ; 交换 dwY[esi] 和 dwY[edi]
        mov eax, dwY[esi]
        mov ebx, dwY[edi]
        mov dwY[esi], ebx
        mov dwY[edi], eax
        
        ; 交换 dwXT[esi] 和 dwXT[edi]
        mov eax, dwXT[esi]
        mov ebx, dwXT[edi]
        mov dwXT[esi], ebx
        mov dwXT[edi], eax
        
        ; 交换 dwYT[esi] 和 dwYT[edi]
        mov eax, dwYT[esi]
        mov ebx, dwYT[edi]
        mov dwYT[esi], ebx
        mov dwYT[edi], eax
        
        ; 移动到下一对
        add esi, 4
        sub edi, 4
    .endw

	;确定新方向
	mov edi, dwSnakeLen
    dec edi
    imul edi, 4

    mov eax, lastX
    mov ebx, dwX[edi]
     .if eax < ebx
    mov dwDirection, 3
    .elseif eax > ebx
    mov dwDirection, 4
    .else
       mov eax, lastY
        mov ebx, dwY[edi]
        .if eax > ebx
        mov dwDirection, 2
        .else
        mov dwDirection, 1
      .endif
    .endif
    ret
_ReverseSnakeBody endp
;***************************************************************************************
;
;技能函数
;
;***************************************************************************************
; 技能处理函数
_UseSkill proc hWnd
    ; 检查技能是否在冷却中
      .if dwCoolDown > 0
	  ret
	  .endif
    ; 激活技能
       mov dwSkillUsed ,  1
    
    ; 根据角色选择不同的技能效果
    mov eax, dwCharacterflag
    .if eax == ID_Character1      ; 角色1技能：分裂
        mov eax, dwSnakeLen
		; 标记技能已使用,进入cd
        mov dwCoolDown, eax
		add dwCoolDown, 5
       ; 保存原始长度		
         push eax            
        ; 计算减半后的长度（最少保留1节）
        mov ebx, 2
        xor edx, edx
        div ebx
        .if eax < 1
            mov eax, 1
        .endif
        
        ; 设置新长度
        mov dwSnakeLen, eax
        pop eax
		sub eax, dwSnakeLen
		add dwExtraScore, eax
       
    .elseif eax == ID_Character2  ; 角色2技能：头尾交换
	  mov eax, dwSnakeLen
        .if eax > 2
             invoke _ReverseSnakeBody
			 mov dwCoolDown, 5
        .endif
        ; 
    .elseif eax == ID_Character3  ; 角色3技能：回出生点
       mov TP_used,1
	   mov dwCoolDown, 5
    .endif
    
    ; 显示技能激活提示
   
    ret
_UseSkill endp
;***************************************************************************************
;
;点更新函数，该函数每调用一次，更新一次位置
;
;***************************************************************************************
_UpdatePosition		proc	_hWnd
					mov eax, 0
					invoke _Rand
					mov esi, dwSnakeLen
					sub esi, 1
					imul esi, 4
					mov eax, dwX[esi]
					mov dwXTemp, eax
					mov eax, dwY[esi]
					mov dwYTemp, eax
					.if TP_used==1
					mov TP_used, 0
					mov dwXTemp, 215
					mov dwYTemp, 15
					mov dwDirection,2
					.endif
					;求出下一个点的位置
					mov esi, dwStep
					mov edx, dwDirection
					.if				edx == 1								;表示向上走
									mov eax, dwYTemp
									sub eax, esi
									mov dwYTemp, eax
					.elseif			edx == 2								;表示向下走
									mov eax, dwYTemp
									add eax, esi
									mov dwYTemp, eax
					.elseif			edx == 3								;表示向左
									mov eax, dwXTemp
									sub eax, esi
									mov dwXTemp, eax
					.elseif			edx == 4								;表示向右
									mov eax, dwXTemp
									add eax, esi
									mov dwXTemp, eax
					.endif

					;判断下一个点是否在蛇中，判断是否碰到边界
					.if dwDirection != 0															;在蛇未停止的情况下才进行判断
						mov esi, dwSnakeLen
						imul esi, 4
						.repeat
							sub esi, 4
							mov eax, dwX[esi]
							mov ebx, dwY[esi]
							.if (dwXTemp > 410 || dwXTemp < 30 || dwYTemp > 410 || dwYTemp < 30) || (eax == dwXTemp && ebx == dwYTemp)
									invoke KillTimer, _hWnd, ID_TIMER								;关闭计时器
									mov	dwXTemp, 0
									mov dwYTemp, 0
									mov dwDirection, 0
									mov ButtonFlag, 2												;修改重玩标志								
									invoke SendMessage,hButton,WM_SETTEXT,0,addr szButton_Restart ;按钮显示重玩
									;弹出重玩提示框
									invoke	MessageBox, NULL, offset szBoxText, offset szBoxTitle, MB_OK
									.break															;跳出循环
							.endif
						.until esi == 0
					.endif

					;wk 判断蛇是否碰上障碍物
					.if dwDirection != 0															;在蛇未停止的情况下才进行判断
						mov esi, barrierNum
						imul esi, 4
						.repeat
							sub esi, 4
							mov eax, barrierX[esi]
							mov ebx, barrierY[esi]
							.if (eax == dwXTemp && ebx == dwYTemp)
									invoke KillTimer, _hWnd, ID_TIMER								;关闭计时器
									mov	dwXTemp, 0
									mov dwYTemp, 0
									mov dwDirection, 0
									mov ButtonFlag, 2												;修改重玩标志
									invoke SendMessage,hButton,WM_SETTEXT,0,addr szButton_Restart ;按钮显示重玩
									;弹出重玩提示框
									invoke	MessageBox, NULL, offset szBoxText, offset szBoxTitle, MB_OK
									.break															;跳出循环
							.endif
						.until esi == 0
					.endif

					;判断当前是否停止，停止之后将下一个点的坐标置为0
					.if			dwDirection == 0								
									mov	dwXTemp, 0
									mov dwYTemp, 0
					.endif

					;jjy 判断模式是否为进阶模式
					.if dwModuleflag == 2
						mov esi, dwSnakeLen
						.repeat
							mov eax, esi
							mov ebx, 10
							mul ebx
							add	eax, 190
							.if eax > 400
								mov eax,400
							.endif
							mov ecx,500
							sub ecx,eax
							mov dwTime, ecx										;随着长度改变速度
							invoke SetTimer, _hWnd, ID_TIMER, dwTime, NULL          
							.break
						.until dwDirection == 0
					.endif


					;绘制分数、模式、角色
					mov eax, dwSnakeLen
					sub eax, 1
					add eax, dwExtraScore
					invoke 	sprintf, offset printBuffer, offset Num, eax ;将分数转化为字符串
					invoke 	SendMessage,hScore,WM_SETTEXT,0,offset printBuffer
					
					invoke	GetDlgItem, _hWnd, ID_MODULESHOW
					.if	dwModuleflag == 0
						invoke  SetWindowText, eax, offset dwMODULESTARTER
					.elseif	dwModuleflag == 1
						invoke  SetWindowText, eax, offset dwMODULESIMPLE
					.elseif	dwModuleflag == 2
						invoke  SetWindowText, eax, offset dwMODULEADVANCED
					.else	;== 3
						invoke  SetWindowText, eax, offset dwMODULEHARD
					.endif

					invoke	GetDlgItem, _hWnd, ID_CharacterShow
					.if	dwCharacterflag == 91
						invoke  SetWindowText, eax, offset dwCHARACTER1
					.elseif	dwCharacterflag == 92
						invoke  SetWindowText, eax, offset dwCHARACTER2
					.else
						invoke  SetWindowText, eax, offset dwCHARACTER3
                    .endif

					mov eax,dwCoolDown					
					invoke sprintf, offset printBuffer, offset Num, eax
					invoke	GetDlgItem, _hWnd, ID_COOLDOWN                   
					invoke SetWindowText, eax, offset printBuffer							
					invoke SetWindowText, eax, 'Q'
		
			

					;判断该点和食物是否相等
					mov eax, dwXTemp
					mov ebx, dwYTemp
					.if eax == dwNextX && ebx == dwNextY && dwXTemp != 0;相等则将该点加入到数组中
									mov esi, dwSnakeLen
									imul esi, 4 
									mov eax, dwNextX
									mov ebx, dwNextY
									mov dwX[esi], eax
									add eax, dwSnakeSize
									mov dwXT[esi], eax					;更新打印终点坐标
									mov dwY[esi], ebx
									add ebx, dwSnakeSize
									mov dwYT[esi], ebx
									add dwSnakeLen, 1
									.if dwCoolDown > 0
									sub dwCoolDown, 1
									.endif

									;更新黑点的位置
									invoke _Rand
									mov eax, dwRandX
									mov dwNextX, eax
									mov eax, dwRandY
									mov dwNextY, eax

									  ; 判断产生的点是否在蛇中 
                                    mov ecx, 100  ; 最大尝试次数
                                     .while ecx > 0
                                      mov esi, dwSnakeLen
                                      imul esi, 4
                                      mov edx, 0  ; 是否在蛇身上的标志
        
                                      .repeat
                                       sub esi, 4
                                       mov eax, dwX[esi]
                                       mov ebx, dwY[esi]
                                       .if eax == dwNextX && ebx == dwNextY
                                        mov edx, 1  ; 在蛇身上
                                       .break
                                       .endif
                                   .until esi == 0
        
                                 .if edx == 0  ; 不在蛇身上，退出循环
                                  .break
                                  .endif
        
                                ; 生成新位置
                                invoke _Rand
                                mov eax, dwRandX
                                mov dwNextX, eax
                                mov eax, dwRandY
                                 mov dwNextY, eax
         
                                 dec ecx
                               .endw
    
                            ; 如果尝试次数用尽，使用备选位置
                            .if ecx == 0
                                 ; 使用固定的备选位置
                               mov dwNextX, 215
                               mov dwNextY, 35
                                 .endif

									;wk 判断生成的点是否在障碍物中
									mov esi, 0
									.repeat
										mov eax, barrierX[esi]
										mov ebx, barrierY[esi]
										.if dwNextX == eax && dwNextY == ebx
											.repeat
												push eax
												push ebx
												push esi
												invoke rand
												pop esi
												mov ebx, 19
												div ebx
												imul edx, dwStep
												add edx, 35
												mov dwNextX, edx

												push esi
												invoke rand
												pop esi
												mov ebx, 19
												div ebx
												imul edx, dwStep
												add edx, 35
												mov dwNextY, edx
												pop ebx
												pop eax
											.until barrierX[esi] != eax || barrierY[esi] != ebx
										.endif
										add esi, 4
										mov ebx, barrierNum
										imul ebx, 4
									.until esi == ebx

					.elseif dwXTemp != 0;不相等，则将原有的数组从0到esi依次递推赋值,更新蛇每一格位置
									mov esi, dwSnakeLen
									imul esi, 4
									mov eax, dwXTemp			;将计算出来的值赋给末尾
									mov dwX[esi], eax
									add eax, dwSnakeSize
									mov dwXT[esi], eax
									mov ebx, dwYTemp
									mov dwY[esi], ebx
									add ebx, dwSnakeSize  ;;;;;
									mov dwYT[esi], ebx    ;;;;;;;;
									mov ebx, 0
									mov edi, 4
									mov eax,dwX[0]
									mov lastX, eax
									mov eax, dwY[0]
									mov lastY,eax
									.repeat
										mov eax, dwX[edi]
										mov dwX[ebx], eax
										add eax, dwSnakeSize	;更新打印终点坐标
										mov dwXT[ebx], eax
										mov eax, dwY[edi]
										mov dwY[ebx], eax
										add eax, dwSnakeSize
										mov dwYT[ebx], eax
										add ebx, 4
										add edi, 4
									.until ebx == esi
					.endif
					ret
_UpdatePosition		endp


;***************************************************************************************
;
;面板绘制函数
;
;***************************************************************************************
_DrawBorad			proc			_hDC
					local			@hdc,@hBMP,@hDCTemp

					invoke 			KillTimer, hWinMain, ID_TIMER

					;创建双缓冲DC
					invoke			GetDC, hWinMain											;获取界面DC
					mov				@hdc, eax
					invoke			CreateCompatibleDC, @hdc								;创建兼容DC
					mov				@hDCTemp, eax
					invoke			CreateCompatibleBitmap, @hdc, 410, 410					;创建兼容位图
					mov				@hBMP, eax
					invoke			SelectObject, @hDCTemp, @hBMP							;将位图选入DC
					invoke			ReleaseDC, hWinMain, @hdc		
					invoke			SelectObject, @hDCTemp, hGameBackgroundBrush
					invoke			PatBlt, @hDCTemp, 0, 0, 420, 420, PATCOPY				;复制

					;绘制游戏界面边框
					invoke          SelectObject, _hDC, hBorderBrush
					invoke			SelectObject, _hDC, hBorderPen
					invoke			Rectangle, _hDC, 20, 20, 30, 420   ;左竖线
					invoke			Rectangle, _hDC, 20, 20, 420, 30	 ;上横线
					invoke			Rectangle, _hDC, 410, 20, 420, 420   ;右竖线
					invoke			Rectangle, _hDC, 20, 410, 420, 420   ;下横线

					;绘制蛇头部和蛇身
					mov				edx, dwSnakeSize 
					mov				ebx, dwSnakeLen
					sub				ebx, 1
					imul			ebx, 4
					mov eax, dwCharacterflag
                     .if eax == ID_Character1      ; 角色1：暗红色
					invoke			SelectObject, @hDCTemp, hSnakeHeadPen1
					invoke			Rectangle, @hDCTemp, dwX[ebx], dwY[ebx], dwXT[ebx], dwYT[ebx]
					invoke			SelectObject, @hDCTemp, hSnakeBodyPen1
					.elseif eax == ID_Character2  ; 角色2：当前颜色
					invoke SelectObject, @hDCTemp, hSnakeHeadPen2
					invoke			Rectangle, @hDCTemp, dwX[ebx], dwY[ebx], dwXT[ebx], dwYT[ebx]
					invoke			SelectObject, @hDCTemp, hSnakeBodyPen2
					.elseif eax == ID_Character3  ; 角色3：紫色
					invoke SelectObject, @hDCTemp, hSnakeHeadPen3
					invoke			Rectangle, @hDCTemp, dwX[ebx], dwY[ebx], dwXT[ebx], dwYT[ebx]
					invoke			SelectObject, @hDCTemp, hSnakeBodyPen3
					.endif
					mov				ebx, dwSnakeLen
					.if				ebx >= 2
									sub				ebx, 1
									imul			ebx, 4
									.repeat			
													sub				ebx, 4
													invoke			Rectangle, @hDCTemp, dwX[ebx], dwY[ebx], dwXT[ebx], dwYT[ebx]
									.until			ebx == 0
					.endif

					
					;绘制猎物
					invoke			SelectObject, @hDCTemp, hFoodPen
					mov				eax, dwNextX
					add				eax, dwSnakeSize
					mov				ebx, dwNextY
					add				ebx, dwSnakeSize
					invoke			Ellipse, @hDCTemp, dwNextX, dwNextY, eax, ebx
					invoke			DeleteObject, eax

					;wk 绘制障碍物
					invoke			SelectObject, @hDCTemp, hBarrierPen
					mov 			ebx, barrierNum
					imul			ebx, 4
					.repeat		
						sub			ebx, 4	
						invoke		Rectangle, @hDCTemp, barrierX[ebx], barrierY[ebx], barrierXT[ebx], barrierYT[ebx]
					.until			ebx == 0

					;为了避免界面闪烁，将新建DC中的画面拷贝到主界面DC中
					invoke			BitBlt, _hDC, 30, 30, 410, 410, @hDCTemp, 30, 30, SRCCOPY
					;删除DC
					invoke			DeleteDC, @hDCTemp	
					invoke SetTimer, hWinMain, ID_TIMER, dwTime, NULL

					ret
_DrawBorad			endp			


;***************************************************************************************
;
;用于绘画右侧信息显示边框
;
;***************************************************************************************
_DrawMsgBorder		proc			_hDC
					invoke			SelectObject, _hDC, hBorderPen
					invoke			Rectangle, _hDC, 420, 20, 610 , 30		;上横线
					invoke			Rectangle, _hDC, 420, 410, 610 , 420	;底部横线
					invoke			Rectangle, _hDC, 610, 20, 620 , 420		;右侧竖线
					ret
_DrawMsgBorder		endp

;***************************************************************************************
;
;绘制菜单背景图片
;
;***************************************************************************************
_DrawMenuBackground proc    _hDC
                    local   @hGraphics, @hBrush, @hBmpGraphics
                    local   @rect:RECT
                    
                     ;如果没有加载图片，直接返回
                    .if     pImage == 0
					      invoke  SelectObject, _hDC, hWhiteBrush
                           invoke  PatBlt, _hDC, 0, 0, 656, 479, PATCOPY
                            ret
                    .endif
                    
                    ; 获取窗口客户区
                    invoke  GetClientRect, hWinMain, addr @rect
                    
                    ; 创建GDI+ Graphics对象
                    invoke  GdipCreateFromHDC, _hDC, addr @hGraphics
                    
                    ; 创建GDI+图像Graphics对象
                    invoke  GdipGetImageGraphicsContext, pImage, addr @hBmpGraphics
                    
                    ; 设置绘图质量
                    invoke  GdipSetSmoothingMode, @hGraphics, SmoothingModeHighQuality
                    invoke  GdipSetInterpolationMode, @hGraphics, InterpolationModeHighQualityBicubic
                    
                    ; 绘制背景图片（拉伸到整个窗口）
                    invoke  GdipDrawImageRectI, @hGraphics, pImage, 
                            0, 0, @rect.right, @rect.bottom
                    
                    ; 清理资源
                    invoke  GdipDeleteGraphics, @hBmpGraphics
                    invoke  GdipDeleteGraphics, @hGraphics
                    
                    ret
_DrawMenuBackground endp
;***************************************************************************************
;
;隐藏菜单窗口
;
;***************************************************************************************
_hideMenuWindow		proc			uses ebx, hWnd

					mov				ebx, 99
					.WHILE	ebx >= 94
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax,SW_HIDE
							dec			ebx
					.ENDW					

					ret
_hideMenuWindow		endp

;***************************************************************************************
;
;显示菜单窗口
;
;***************************************************************************************
_showMenuWindow		proc			uses ebx, hWnd
                     mov     menuFlag, 0  
					mov				ebx, 98
					.WHILE	ebx >= 95
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax, SW_SHOW							
							dec			ebx
					.ENDW
					; 强制重绘背景
                    invoke  InvalidateRect, hWnd, NULL, TRUE
					ret
_showMenuWindow		endp

;***************************************************************************************
;
;显示选择模式窗口
;
;***************************************************************************************
_showModuleWindow	proc			uses ebx, hWnd
					mov				ebx, 109
					.WHILE	ebx >= 106
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax, SW_SHOW
							dec			ebx
					.ENDW

					invoke		GetDlgItem, hWnd, 99
					push		eax
					invoke		ShowWindow, eax, SW_SHOW
					pop			eax
					invoke  	SetWindowText, eax, offset dwMODULESET
					
					ret
_showModuleWindow	endp

;***************************************************************************************
;
;隐藏选择模式窗口
;
;***************************************************************************************
_hideModuleWindow	proc			uses ebx, hWnd
					mov				ebx, 109
					.WHILE	ebx >= 106
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax, SW_HIDE
							dec			ebx
					.ENDW

					invoke		GetDlgItem, hWnd, 99
					invoke		ShowWindow, eax, SW_HIDE
					;invoke  	SetWindowText, eax, offset szClassName
					

					ret
_hideModuleWindow	endp

;***************************************************************************************
;
;显示选择角色窗口
;
;***************************************************************************************
_showCharacterWindow	proc			uses ebx, hWnd
                    mov menuFlag, 2                     
					mov				ebx, 93
					.WHILE	ebx >= 91
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax, SW_SHOW
							dec			ebx
					.ENDW
					
					invoke		GetDlgItem, hWnd, 99
					push		eax
					invoke		ShowWindow, eax, SW_SHOW
					pop			eax
					invoke  	SetWindowText, eax, offset dwCharacterSET

					; 强制重绘背景
                    invoke  InvalidateRect, hWnd, NULL, TRUE
					ret
_showCharacterWindow	endp

 _drawCharacter  proc    hDC
    ; 清除背景
    ;invoke  SelectObject, hDC, hWhiteBrush
   ; invoke  PatBlt, hDC, 0, 0, 656, 479, PATCOPY      
    
   
    
    ; 绘制角色1样例（分裂蛇）在第一个按钮上方
    invoke  SelectObject, hDC, hSnakeHeadPen1
    invoke  Rectangle, hDC, 160, 150, 170, 160     ; 蛇头
    
    invoke  SelectObject, hDC, hSnakeBodyPen1
    invoke  Rectangle, hDC, 160, 170, 170, 180     ; 蛇身第1节
    invoke  Rectangle, hDC, 160, 190, 170, 200     ; 蛇身第2节
    invoke  Rectangle, hDC, 160, 210, 170, 220    ; 蛇身第3节
    
    ; 绘制角色2样例（无头蛇）在第二个按钮上方
    invoke  SelectObject, hDC, hSnakeHeadPen2
    invoke  Rectangle, hDC, 310, 260, 320, 270   ; 蛇头
    
    invoke  SelectObject, hDC, hSnakeBodyPen2
    invoke  Rectangle, hDC, 310, 280, 320, 290   ; 蛇身第1节
    invoke  Rectangle, hDC, 310, 300, 320, 310   ; 蛇身第2节
    invoke  Rectangle, hDC, 310, 320, 320, 330   ; 蛇身第3节
    
    ; 绘制角色3样例（虫洞蛇）在第三个按钮上方
    invoke  SelectObject, hDC, hSnakeHeadPen3
    invoke  Rectangle, hDC, 460, 150, 470, 160   ; 蛇头
    
    invoke  SelectObject, hDC, hSnakeBodyPen3
    invoke  Rectangle, hDC, 460, 170, 470, 180   ; 蛇身第1节
    invoke  Rectangle, hDC, 460, 190, 470, 200   ; 蛇身第2节
    invoke  Rectangle, hDC, 460, 210, 470, 220   ; 蛇身第3节
    
   
	ret
  _drawCharacter endp  
    
					

;***************************************************************************************
;
;隐藏选择角色窗口
;
;***************************************************************************************
_hideCharacterWindow	proc			uses ebx, hWnd
					mov				ebx, 93
					.WHILE	ebx >= 91
							invoke		GetDlgItem, hWnd, ebx
							invoke		ShowWindow, eax, SW_HIDE							
							dec			ebx
					.ENDW

					invoke		GetDlgItem, hWnd, 99
					invoke  	ShowWindow, eax, SW_HIDE

					ret
_hideCharacterWindow	endp


;***************************************************************************************
;
;显示新游戏的窗口
;
;***************************************************************************************
_showGameWindow		proc			hWnd
					local			@stRect:RECT
					
					;需要重绘的矩形区域
					mov @stRect.left, 0
					mov @stRect.right, 656
					mov @stRect.top, 0
					mov @stRect.bottom, 479
					invoke 			InvalidateRect, hWnd, addr @stRect, FALSE
					
					invoke			GetDlgItem, hWnd, 50
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, ID_SCORE
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, ID_STOP
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, 51
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, ID_MODULESHOW
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, 52
					invoke			ShowWindow, eax, SW_SHOW
					
					invoke			GetDlgItem, hWnd, 53
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, ID_CharacterShow
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, 54
					invoke			ShowWindow, eax, SW_SHOW
					invoke			GetDlgItem, hWnd, ID_COOLDOWN
					invoke			ShowWindow, eax, SW_SHOW
					
					ret
_showGameWindow		endp

;***************************************************************************************
;
;隐藏新游戏的窗口
;
;***************************************************************************************

_hideGameWindow		proc			hWnd
					local			@stRect:RECT
					;需要重绘的矩形区域
					mov @stRect.left, 0
					mov @stRect.right, 656
					mov @stRect.top, 0
					mov @stRect.bottom, 479
					invoke 			InvalidateRect, hWnd, addr @stRect, FALSE
					invoke			GetDlgItem, hWnd, 50
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, ID_SCORE
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, ID_STOP
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, 51
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, ID_MODULESHOW
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, 52
					invoke			ShowWindow, eax, SW_HIDE
					
					invoke			GetDlgItem, hWnd, 53
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, ID_CharacterShow
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, 54
					invoke			ShowWindow, eax, SW_HIDE
					invoke			GetDlgItem, hWnd, ID_COOLDOWN
					invoke			ShowWindow, eax, SW_HIDE
					invoke		    GetDlgItem, hWnd, ID_Continue
					invoke		    ShowWindow, eax, SW_HIDE
					ret
_hideGameWindow		endp


;***************************************************************************************
;
;消息函数，处理各种消息
;
;***************************************************************************************
_ProcWinMain		proc			uses ebx edi esi hWnd, uMsg, wParam, lParam
					local			@stPS:PAINTSTRUCT
					local			@stRect:RECT
					local			@hDC, @hBMP
					;需要重绘的矩形区域
					mov @stRect.left, 30
					mov @stRect.right, 410
					mov @stRect.top, 30
					mov @stRect.bottom, 410
					.if				uMsg == WM_TIMER										;计时器到时
									invoke 	_UpdatePosition, hWnd
									;这里可以精确设置重绘区域使得效率更高
									invoke 	InvalidateRect, hWnd, addr @stRect, FALSE		;定时器到时,发送重绘命令，但是不刷新界面
					.elseif			uMsg == WM_PAINT
									invoke BeginPaint, hWnd, addr @stPS
									mov @hDC, eax
									.IF	menuFlag == 1
										invoke _DrawBorad, @hDC									;调用绘画界面函数
										invoke _DrawMsgBorder, @hDC								;绘画右侧边框
									.ELSEIF menuFlag == 0
									     invoke _DrawMenuBackground, @hDC                       
								    .ELSEIF  menuFlag == 2
									     invoke _DrawMenuBackground, @hDC
									     invoke _drawCharacter, @hDC                           ;调用绘画三个角色函数

									.ELSE 
										invoke			SelectObject, @hDC, hWhiteBrush
										invoke			PatBlt, @hDC, 0, 0, 656, 479, PATCOPY
									.ENDIF
									invoke EndPaint, hWnd, addr @stPS
					.elseif			uMsg == WM_CREATE
									; invoke SetTimer, hWnd, ID_TIMER, dwTime, NULL			;设置定时器

									
									;创建标题显示区域
									invoke	CreateWindowEx, WS_EX_TRANSPARENT,\
											offset szStatic, offset szClassName,\
											WS_CHILD  or SS_CENTER or WS_EX_TRANSPARENT,\
											220, 20, 200, 70,\
											hWnd, 99, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_big, NULL

									;新游戏按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szNewGame,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											50, 250, 100, 50,\
											hWnd, ID_NewGame, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;设置模式按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szSetModule,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											500, 250, 100, 50,\
											hWnd, ID_SetModule,	 hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;帮助按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szHelp,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											200, 250, 100, 50,\
											hWnd, ID_HELP, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL
									
									;关于按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szAbout,\
											WS_CHILD or WS_VISIBLE or BS_FLAT,\
											350, 250, 100, 50,\
											hWnd, ID_About, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL
									
									;----------------------------------------------------------
									
									;入门模式设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULESTARTER,\
											WS_CHILD or BS_FLAT,\
											270, 130, 100, 50,\
											hWnd, ID_MODULESTARTER, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;简单模式设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULESIMPLE,\
											WS_CHILD or BS_FLAT,\
											270, 190, 100, 50,\
											hWnd, ID_MODULESIMPLE, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;进阶模式设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULEADVANCED,\
											WS_CHILD or BS_FLAT,\
											270, 250, 100, 50,\
											hWnd, ID_MODULEADVANCED, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;困难模式设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwMODULEHARD,\
											WS_CHILD or BS_FLAT,\
											270, 310, 100, 50,\
											hWnd, ID_MODULEHARD, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;----------------------------------------------------------
									
									;角色1设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwCHARACTER1,\
											WS_CHILD or BS_FLAT,\
											110, 260, 100, 50,\
											hWnd, ID_Character1, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;角色2设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwCHARACTER2,\
											WS_CHILD or BS_FLAT,\
											260, 160, 100, 50,\
											hWnd, ID_Character2, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

									;角色3设置按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset dwCHARACTER3,\
											WS_CHILD or BS_FLAT,\
											410, 260, 100, 50,\
											hWnd, ID_Character3, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

						

									;----------------------------------------------------------
									
									;创建分数显示区域
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit, offset dwSCORE,\
											WS_CHILD  ,\
											440, 310, 70, 30,\
											hWnd, 50, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit,offset Blank ,\
											WS_CHILD  ,\
											520, 310, 70, 30,\
											hWnd, ID_SCORE, hInstance, NULL
									mov		hScore, eax
									invoke  SendMessage,
											hScore,
											WM_SETFONT,
											hFont_Show, NULL

									;创建模式显示区域
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit, offset dwMODULE,\
											WS_CHILD  ,\
											440, 350, 70, 30,\
											hWnd, 51, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit,offset Blank ,\
											WS_CHILD  ,\
											520, 350, 70, 30,\
											hWnd, ID_MODULESHOW, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL

								
									;创建角色显示区域
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit, offset dwCHARACTER,\
											WS_CHILD  ,\
											440, 80, 70, 30,\
											hWnd, 53, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit,offset Blank ,\
											WS_CHILD  ,\
											520, 80, 80, 30,\
											hWnd, ID_CharacterShow, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL

									;创建cd显示区域
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit, offset dwCOOLDOWN,\
											WS_CHILD  ,\
											440, 120, 70, 30,\
											hWnd, 54, hInstance, NULL 
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL
									invoke	CreateWindowEx, ES_LEFT,\
											offset szEdit,offset Blank ,\
											WS_CHILD  ,\
											520, 120, 70, 30,\
											hWnd, ID_COOLDOWN, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_Show, NULL
                                

									;暂停/开始/重玩按钮
									invoke	CreateWindowEx, NULL,\
											offset szButton, offset szButton_Stop,\
											WS_CHILD   or BS_FLAT,\								
											460, 200, 100, 50,\
											hWnd, ID_STOP, hInstance, NULL
									mov		hButton,eax
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL
								   ;继续按钮
									invoke	CreateWindowEx, ES_LEFT,\
											offset szButton, offset szContinue,\
											WS_CHILD or BS_FLAT,\
											460, 200, 100, 50,\
											hWnd, ID_Continue, hInstance, NULL
									invoke  SendMessage,
											eax,
											WM_SETFONT,
											hFont_small, NULL

					.elseif			uMsg == WM_KEYDOWN
									mov eax,wParam
									mov ebx, dwDirection
									.if	eax == VK_UP													;w键表示向上
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_UP,0		
									.elseif eax == VK_DOWN												;s键表示向下
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_DOWN,0
									.elseif eax == VK_LEFT												;a键表示向左
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_LEFT,0
									.elseif eax == VK_RIGHT												;d键表示向右
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_RIGHT,0
									.elseif	eax == 87													;w键表示向上
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_UP,0		
									.elseif eax == 83													;s键表示向下
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_DOWN,0
									.elseif eax == 65													;a键表示向左
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_LEFT,0
									.elseif eax == 68													;d键表示向右
											invoke _ProcWinMain,hWnd,WM_COMMAND,ID_RIGHT,0
                                    .elseif eax == 81                                        ; Q键技能
                                            invoke _ProcWinMain,hWnd,WM_COMMAND,ID_SKILL,0

									.endif
									
									
					.elseif			uMsg == WM_COMMAND												
									mov eax,wParam
									mov ebx, dwStep		
									mov esi, dwDirection
									.if	eax == ID_UP && ButtonFlag < 2 && esi != 2					;设置蛇不能转向相反方向
											mov dwDirection, 1
									.elseif eax == ID_DOWN && ButtonFlag != 2 && esi != 1	
											mov dwDirection, 2
									.elseif eax == ID_LEFT && ButtonFlag != 2 && esi != 4
											mov dwDirection, 3
									.elseif	eax == ID_RIGHT && ButtonFlag != 2 && esi != 3	
											mov dwDirection, 4

									.elseif eax == ID_STOP
									    .IF ButtonFlag == 2      ; 游戏结束状态，按钮显示"重玩"
                                         ; 重玩游戏
                                         invoke _Init              ; 重新初始化游戏
                                         mov dwDirection, 2        ; 设置初始方向
                                         mov ButtonFlag, 1         ; 设置为运动状态
                                         invoke SendMessage, hButton, WM_SETTEXT, 0, addr szButton_Stop
                                         invoke SetTimer, hWnd, ID_TIMER, dwTime, NULL
                                         invoke InvalidateRect, hWnd, NULL, TRUE
                                           .ELSE                     ; 其他状态（暂停/继续）
											mov dwDirectionTemp, esi
											mov dwDirection, 0
											mov menuFlag, 0											
											invoke			GetDlgItem, hWnd, ID_STOP
					                        invoke			ShowWindow, eax, SW_HIDE
											invoke			GetDlgItem, hWnd, ID_Continue
					                        invoke			ShowWindow, eax, SW_SHOW										
											invoke 	KillTimer, hWnd, ID_TIMER
                                           .ENDIF

									.elseif	eax == ID_MODULESTARTER		;入门级难度										;处理速度切换按钮
											mov	dwModuleflag, 0
											mov dwTime, 500				;重新设置定时器间隔
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif	eax == ID_MODULESIMPLE		;简单难度	
											mov dwModuleflag, 1
											mov dwTime, 300
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif eax == ID_MODULEADVANCED	;进阶难度
											mov dwModuleflag, 2
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif	eax == ID_MODULEHARD		;困难难度
											mov dwModuleflag, 3
											mov dwTime, 100	
											invoke	_hideModuleWindow, hWnd
											invoke	_showMenuWindow, hWnd
									.elseif	eax == ID_SetModule	
											invoke	_hideMenuWindow, hWnd
											invoke	_showModuleWindow, hWnd
									.elseif eax == ID_HELP
										invoke	MessageBox, hWnd, offset szHelpText, offset szHelp, MB_OK	
									.elseif eax == ID_About
										invoke	MessageBox, hWnd, offset szAboutText, offset szAbout, MB_OK	
									.elseif	eax == ID_NewGame		;新游戏
											invoke	_hideMenuWindow, hWnd
									;		invoke	_showGameWindow, hWnd
										;	invoke 	SetTimer, hWnd, ID_TIMER, dwTime, NULL	;设置定时器
									        invoke  _showCharacterWindow, hWnd
									.elseif eax >= ID_Character1 && eax <= ID_Character3
									        mov		continueBtnFlag, 1
											mov     dwCharacterflag, eax
											mov 	ButtonFlag, 1
											invoke 	_Init
											mov		menuFlag, 1	
									        invoke	_hideCharacterWindow, hWnd
											invoke	_showGameWindow, hWnd
											invoke 	SetTimer, hWnd, ID_TIMER, dwTime, NULL	;设置定时器
                                   
                                   .elseif eax == ID_SKILL             ; 技能
                                          invoke _UseSkill, hWnd


									.elseif	eax == ID_Continue
											mov edx, dwDirectionTemp
											mov dwDirection, edx
											mov menuFlag, 1
											mov ButtonFlag, 0
											;invoke	_hideMenuWindow, hWnd
											;invoke	_showGameWindow, hWnd
											invoke			GetDlgItem, hWnd, ID_Continue
					                        invoke			ShowWindow, eax, SW_HIDE
											invoke			GetDlgItem, hWnd, ID_STOP
					                        invoke			ShowWindow, eax, SW_SHOW
											invoke SetTimer, hWnd, ID_TIMER, dwTime, NULL
									.endif 
									.if    	ButtonFlag != 2
											invoke SetFocus, hWnd										;游戏中总是让窗口获得焦点
									.endif
			
					
									
					.elseif			uMsg == WM_CLOSE
									invoke KillTimer, hWnd, ID_TIMER
									invoke DeleteObject, hGameBackgroundBrush  ; 清理画刷画笔					
					                invoke DeleteObject, hWhiteBrush
					                 invoke DeleteObject, hBorderBrush
					                invoke DeleteObject, hBorderPen
									invoke DestroyWindow, hWinMain
									invoke PostQuitMessage, NULL
					.else
									invoke DefWindowProc, hWnd, uMsg, wParam, lParam
									ret
					.endif
					xor				eax, eax
					ret
_ProcWinMain		endp


;***************************************************************************************
;
;注册并创建窗口函数
;
;***************************************************************************************
_WinMain			proc
					local			@stWndClass:WNDCLASSEX
					local			@stMsg:MSG
					invoke			GetModuleHandle, NULL
					mov				hInstance, eax

					;注册窗口类
					invoke			RtlZeroMemory, addr @stWndClass, sizeof @stWndClass
					invoke			LoadIcon, hInstance, IDI_ICON
					mov				@stWndClass.hIcon, eax
					mov				@stWndClass.hIconSm, eax
					invoke			LoadCursor, 0, IDC_ARROW
					mov				@stWndClass.hCursor, eax
					push			hInstance
					pop				@stWndClass.hInstance
					mov				@stWndClass.cbSize, sizeof WNDCLASSEX
					mov				@stWndClass.style, CS_HREDRAW or CS_VREDRAW
					mov				@stWndClass.lpfnWndProc, offset _ProcWinMain
					mov				@stWndClass.hbrBackground, COLOR_WINDOW + 1
					mov				@stWndClass.lpszClassName, offset szClassName
					invoke			RegisterClassEx, addr @stWndClass

					;建立并显示窗口
					invoke			CreateWindowEx,NULL, \
									offset szClassName, offset szClassName,\
									 WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX,\
									CW_USEDEFAULT, CW_USEDEFAULT, \
									656, 479,\
									NULL, NULL, hInstance, NULL
					mov				hWinMain, eax
					invoke			ShowWindow, hWinMain, SW_SHOWNORMAL
					invoke			UpdateWindow, hWinMain

					;消息循环
					.while			TRUE
									invoke GetMessage, addr @stMsg, NULL, 0, 0
									.break .if eax == 0
									invoke TranslateMessage, addr @stMsg
									invoke DispatchMessage, addr @stMsg
					.endw
					ret
_WinMain			endp

;***************************************************************************************
;
;主函数，程序入口
;
;***************************************************************************************
main				proc
                     
					 local   @stGdiplusStartupInput:GdiplusStartupInput		

                    ; 初始化GDI+
                    mov     @stGdiplusStartupInput.GdiplusVersion, 1
                    mov     @stGdiplusStartupInput.DebugEventCallback, NULL
                    mov     @stGdiplusStartupInput.SuppressBackgroundThread, FALSE
                    mov     @stGdiplusStartupInput.SuppressExternalCodecs, FALSE
                    
                    invoke  GdiplusStartup, addr gdiplusToken, addr @stGdiplusStartupInput, NULL
					
                    ; 加载菜单背景图片
					invoke MultiByteToWideChar,CP_ACP,0,addr szMenuBackground,12,offset wzMenuBackground,200 
                    invoke  GdipLoadImageFromFile, offset wzMenuBackground, addr pImage					  

					;调用初始化函数初始化寄存器的值
					invoke			_Init
					invoke			_createFont
					invoke			_createPens				

					;调用窗口注册函数
					call			_WinMain
					invoke			ExitProcess, NULL
main				endp
end					main