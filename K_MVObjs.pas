unit K_MVObjs;
//*** MVDar Objects classes
interface
uses
  Classes, IniFiles, Types, Grids, Graphics, StdCtrls,
  K_IMVDAR, K_DCSpace, K_UDT1, K_SCript1, K_FrRAEdit, K_RAEdit,
  N_ClassRef, N_Types, N_GCont;


//********************************
//  Web Events and EventScripts
//********************************
type TK_MVEvtFlags0 = Set Of (
         K_evfWaitRcpnt {= "Ждать ативизации Получателя"} );
type TK_MVEvtFlags = packed record
    case Integer of
      0: ( T : TK_MVEvtFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVEvtFlags = record

type TK_MVEvtMask0 = Set Of (
         K_evmRejectWaitEvt {= "Не принимать ожидающие события"} );
type TK_MVEvtMask = packed record
    case Integer of
      0: ( T : TK_MVEvtMask0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVEvtMask = record

type TK_MVProgEvent = packed record // MV Program Event
  EvtFlags  : TK_MVEvtFlags; // Event Flags
  EvtID     : String;    // Event Identifier
  TargetObj : TN_UDBase; // Target Web Object - TK_MVWebWinObj
end; // type TK_MVProgEvent = record

type TK_MVCSElemEvent = packed record // MV Code Space Event
  EvtFlags : TK_MVEvtFlags; // Event Flags
  CS       : TN_UDBase; // Web Client Code Space
  CInd     : Integer;   // New CSS Index
end; // type TK_MVCSElemEvent = record

type TK_MVDefDocPartEvent = packed record // MV Redefined Document Part
  EvtFlags  : TK_MVEvtFlags; // Event Flags
  WCIWDescr : TN_UDBase; // Web Client Interface Window Description
  Content   : String; // Redefined Document Part Content
end; // type TK_MVDefDocPartEvent = record

type TK_MVWebScript = packed record // MV Script
  EvtID    : String;  // Event Identifier
  EvtMasks : TK_MVEvtMask; // Event Mask
  RDPList  : TK_RArray; // Redefined document parts List - ArrayOf TK_MVDefDocPartEvent
  WWList   : TK_RArray; // List of TK_MVWebWinObj Objects which must be open - ArrayOf TN_UDBase
  CECList  : TK_RArray; // List of CSE Events - ArrayOf TK_MVCSElemEvent
  MVVList  : TK_RArray; // List of MVV Events - ArrayOf TK_MVVectorEvent
  PEList   : TK_RArray; // List of Program Events - ArrayOf TK_MVProgEvent
  AScript  : TK_RArray; // JS operators - ArrayOf String
end; // type TK_MVWebScript = record
type TK_PMVWebScript = ^TK_MVWebScript;

//*** end of Web Events and EventScripts


//********************************
//  Web Line Diagram Style Types
//********************************

type TK_MVWLDStyle = packed record // MV Line Diagram Style Attributes
  TableStyle   : string; // Table Style Attributes (Border, BGround ...)
  OddRowStyle  : string; // Odd Row Style Attributes
  EvenRowStyle : string; // Even Row Style Attributes
  SelRowStyle  : string; // Selected Row Style Attributes
  CaptionStyle : String; // Caption Style Attributes (Font ...)
  NamesFStyle  : String; // Diagram Elements Names Font Style Attributes (Font ...)
  ValuesFStyle : String; // Diagram Elements Values Font Style Attributes (Font ...)
  BarStyle     : string; // Bar Style Attributes
  VarBarImg    : String; // Variable Diagram Bar Image File Name
  FixBarImg    : string; // Fixed  Diagram Bar Image File Name
end; // type TK_MVWLDStyle = record

//*** end of Web Line Diagram Style Types

//********************************
//  Web Table Style Types
//********************************
type TK_MVWTStyle = packed record // MV Table Style Attributes
  TableStyle     : string; // Table Style Attributes (Border, BGround ...)
  OddRowStyle    : string; // Odd Row Style Attributes
  EvenRowStyle   : string; // Even Row Style Attributes
  SelRowStyle    : string; // Selected Row Style Attributes
  SelColStyle    : string; // Selected Column Style Attributes
  ColHeaderStyle : String; // Column Headers Style Attributes (Font ...)
  RowHeaderStyle : String; // Row Headers Style Style Attributes (Font ...)
end; // type TK_MVWTStyle = record

//*** end of Web Table Style Types

//********************************
//  Web Objects Abstract Types
//********************************
type TK_MVWebWinFlags0 = Set Of (
         K_wwfCaptionToWWTitle {= "Отображать название в заголовке окна"} );
type TK_MVWebWinFlags = packed record
    case Integer of
      0: ( T : TK_MVWebWinFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVEvtMask = record

type TK_MVWebWinObj = packed record // MV Web Client Interface Object shown in Window
// Web Object Captions
  FullCapt  : string;   // Web Object Object Caption
  BriefCapt : string;   // Web Object Object Caption
// Web Object Story Attributes
  Title     : string;    // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
end; // type TK_MVWebWinObj = record
type TK_PMVWebWinObj = ^TK_MVWebWinObj;

//*** end of Web Objects Abstract Types


//********************************
//  MV Client UDRArray Objects Prototype
//********************************
type TK_UDMVWBase  = class( TK_UDRArray ) //*** Web Base Object
  function  CanMoveChilds : Boolean; override;
  function  CanMoveDE( const DE : TN_DirEntryPar ): Boolean; override;
  function  CanAddChild( Child : TN_UDBase ): Boolean; override;
  function  AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = []  ) : Boolean; override;
  function  RemoveSelfFromSubTree( PDE : TK_PDirEntryPar ) : Boolean; override;
  function  DeleteSubTreeChild( Index : Integer ) : Boolean; override;
end; //*** end of type TK_UDMVWBase  = class( TK_UDRArray )

//********************************
//  MVDar Main Folder
//********************************
type TK_UDMVFolder  = class( TN_UDBase )
  constructor Create; override;
  function  CanMoveChilds : Boolean; override;
  function  CanMoveDE( const DE : TN_DirEntryPar ): Boolean; override;
  function  CanAddChild( Child : TN_UDBase ): Boolean; override;
  function  CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function  AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
  function  RemoveSelfFromSubTree( PDE : TK_PDirEntryPar ) : Boolean; override;
  function  DeleteSubTreeChild( Index : Integer ) : Boolean; override;
end; //*** end of type TK_UDMVFolder  = class( TN_UDBase )

//*** end of MVDar Main Folder

//********************************
//  Web Windows Layout Objects
//********************************

type TK_MVVWViewFlags0 = Set of ( //*** MV Web Virtual WIndow Browser View Flags
         K_wofResizable,  // resizable window - = "Можно изменять размер"
         K_wofScrollbars, // show Scrollbars  - = "Показывать полосы прокрутки"
         K_wofMenubar,    // show Menubar  - = "Показывать меню"
         K_wofToolbar,    // show Toolbar  - = "Показывать панель инструментов"
         K_wofLocation,   // show Locationbar  - = "Показывать адрес"
         K_wofStatus      // show Statusbar  - = "Показывать состояние"
         );

type TK_MVVWViewFlags = packed record
    case Integer of
      0: ( T : TK_MVVWViewFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVVWViewFlags = record

type TK_MVVWCreateFlags0 = Set of ( //*** MV Web Virtual WIndow Create Flags
         K_wcfNewObjNewWin, // Create New Window for New VObj  - = "Новое окно для разных объектов"
         K_wcfAllObjNewWin // Create New Window for All VObj  - = "Новое окно для любых объектов"
         );

type TK_MVVWCreateFlags = packed record
    case Integer of
      0: ( T : TK_MVVWCreateFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVVWCreateFlags = record

type TK_MVVWScriptFlags0 = Set of ( //*** MV Web Virtual WIndow Script Flags
         K_wsfSkipFocusOnChange // Skip Set Focus on VObj view change    - = '"Не всплывать" при изменении объекта'
         );

type TK_MVVWScriptFlags = packed record
    case Integer of
      0: ( T : TK_MVVWScriptFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVVWStrategyFlags = record

type TK_MVVWindow = packed record //*** MV Web Virtual Window Attributes (*TK_UDMVVWindow*)
  VWName    : string;  // Virtual Window Name must be shown in UDObj.Aliase as 'Виртуальное окно "Name"'
  VWCaption : string;  // Virtual Window Static Caption
  Left      : float;   // Reliable Left Position
  Top       : float;   // Reliable Top Position
  Width     : float;   // Reliable Width
  Height    : float;   // Reliable Height
  ViewFlags     : TK_MVVWViewFlags;   // Window View flags
  CreateFlags   : TK_MVVWCreateFlags; // Window Create flags
  ScriptFlags   : TK_MVVWScriptFlags; // Window Script flags
end; // type TK_MVVWindow = record
type TK_PMVVWindow = ^TK_MVVWindow;

type TK_UDMVVWindow = class( TK_UDMVWBase )
  constructor Create; override;
  function    CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  procedure   GetMVVWindows( MVVWindowsInfo : TStrings; SaveFrameSets : Boolean );
end; //*** end of type TK_UDMVVWindow  = class( TK_UDMVWBase )

type TK_MVVWFrameFlags0 = Set of ( //*** MV Web Virtual Frame Mode Flags
         K_fmfSkipBorders, // Skip Frame Border = 'Запрет показа границ'
         K_fmfSkipResize,  // Skip Frame Resize = 'Запрет изменения размера'
         K_fmfShowDocTitle // Show Document Title = 'Показ заголовка документа в заголовке окна'  
         );

type TK_MVVWFrameFlags = packed record
    case Integer of
      0: ( T : TK_MVVWFrameFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVVWFrameFlags = record

type TK_MVVWFrameScrollMode = ( //*** MV Web Virtual Frame Scroll Mode
         K_fsmAuto, // Default. Browser determines whether scroll bars are necessary = 'Определяется браузером'
         K_fsmYes,  // Frame can be scrolled = 'Разрешение прокрутки'
         K_fsmNo    // Frame cannot be scrolled = 'Запрет прокрутки'
         );

type TK_MVVWFrame = packed record //*** MV Web Frame Window (*TK_UDMVVWFrame*)
  VWName       : string;  // Virtual Window Name must be shown in UDObj.Aliase as 'Виртуальное окно "Name"'
  MarginHeight : Integer; // in Pixels
  MarginWidth  : Integer; // in Pixels
  ModeFlags    : TK_MVVWFrameFlags;
  ScrollMode   : TK_MVVWFrameScrollMode;
  BorderColor  : string;  // Frame Border Color      - *
  Width        : string; // in Pixels or Percentage  - *
  Height       : string; // in Pixels or Percentage  - *
end; // type TK_MVVWFrame = record
type TK_PMVVWFrame = ^TK_MVVWFrame;

type TK_UDMVVWFrame = class( TK_UDMVWBase )
  constructor Create; override;
  procedure   AddHTMStrings( HTMInfo : TStrings; PreviewMode : Boolean ); virtual;
end; //*** end of type TK_UDMVVWFrame  = class( TK_UDMVWBase )

type TK_MVVWFrameSetFlags0 = Set of ( //*** MV Web Virtual Frame Set Mode Flags
         K_fsmfSkipBorders, // Skip Set Frames Border       = 'Запрет показа границ'
         K_fsmfVertical     // Set Frames Verical Direction = 'Вертикальная ориентация фреймов'
         );

type TK_MVVWFrameSetFlags = packed record
    case Integer of
      0: ( T : TK_MVVWFrameSetFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVVWFrameSetFlags = record

type TK_MVVWFrameSet = packed record //*** MV Web Frame Set  (*TK_UDMVVWFrameSet*)
  ModeFlags    : TK_MVVWFrameSetFlags;
  ElemsSize    : TK_RArray; // ArrayOf String; // Set Frames Size in Pixels or Percentage
  BorderWidth  : Integer;   // in Pixels - *
  FrameSpacing : Integer;   // in Pixels - *
  Width        : string;    // in Pixels or Percentage  - *
  Height       : string;    // in Pixels or Percentage  - *
  VName         : string;   // Frames Set VName - *
end; // type TK_MVVWFrameSet = record
type TK_PMVVWFrameSet = ^TK_MVVWFrameSet;

type TK_UDMVVWFrameSet = class( TK_UDMVVWFrame )
  constructor Create; override;
  function    CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function    AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
  function    DeleteSubTreeChild( Index : Integer ) : Boolean; override;
  procedure   MoveSubTreeChilds(dInd, sInd, mcount: Integer); override;
  procedure   AddHTMStrings( HTMInfo: TStrings; PreviewMode : Boolean ); override;
  procedure   GetMVVWFrames( MVVWindowsInfo : TStrings;
                      MainFrameSet : TN_UDBase; SaveFrameSets : Boolean );
end; //*** end of type TK_UDMVVWFrameSet  = class( TK_UDMVWBase )

type TK_UDMVVWLayout = class( TK_UDMVFolder )
  constructor Create; override;
  function    CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function    AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
  procedure   GetMVVWindowList( VWList : TStrings; SaveFrameSets : Boolean );
end; //*** end of type TK_UDMVVWLayout  = class( TK_UDMVFolder )

//*** end of Web Windows Layout Objects

//********************************
//  Web Objects Common Fields
//********************************

type TK_MVWGECaptsType0 = ( //*** Group Elements Captions Type
         K_gecWEFull,  // Web Object Full Caption = "Собственное полное название элемента"
         K_gecWEBrief, // Web Object Brief Caption = "Собственное краткое название элемента"
         K_gecWEParent // Web Object Parent Caption = "Название элемента задано родителем"
         );

type TK_MVWGECaptsType = packed record
    case Integer of
      0: ( T : TK_MVWGECaptsType0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVWGECaptsType = record

//*** end of Web Objects Common Fields

//********************************
//  Web Objects
//********************************

type TK_MVWebFolder = packed record //*** TK_MVWebFolder (*TK_UDMVWFolder*)
// Web Object Captions
  FullCapt  : string;   // Web Object Full Caption
  BriefCapt : string;   // Web Object Brief Caption
// TK_MVWebGroupElemsCapts
  WENType  : TK_MVWGECaptsType; // Elements Captions Type
  WECapts  : TK_RArray;         // Elements Group Captions - ArrayOf string
end; // type TK_MVWebFolder = record
type TK_PMVWebFolder = ^TK_MVWebFolder;

type TK_MVWebFolderCD = packed record // TK_MVWebFolder Common Data Editor Structure
  FullCapt  : string;   // Web Object Full Caption
  BriefCapt : string;   // Web Object Brief Caption
  WENType  : TK_MVWGECaptsType; // Elements Captions Type
end; // type TK_MVWebFolderLE = record
type TK_PMVWebFolderCD = ^TK_MVWebFolderCD;

type TK_MVWebFolderLE = packed record // TK_MVWebFolder List Element Editor Structure
  LENode    : TN_UDBase;   // List Element Node
  LECaption : string;      // Web Object Brief Caption
end; // type TK_MVWebFolderLE = record
type TK_PMVWebFolderLE = ^TK_MVWebFolderLE;

type TK_UDMVWFolder  = class( TK_UDMVWBase ) //*** Web Folder UDBase
  constructor Create; override;
  function  CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function  AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
  procedure MoveSubTreeChilds( dInd, sInd: Integer; mcount : Integer = 1 ); override;
  function  DeleteSubTreeChild( Index : Integer ) : Boolean; override;
end; //*** end of type TK_UDMVWFolder  = class( TK_UDMVWBase )

type TK_MVWebVTreeWin = packed record   //*** WEB Structure Window (*TK_UDMVWVTreeWin*)
// Web Object Captions
  FullCapt  : string;   // Web Object Full Caption
  BriefCapt : string;   // Web Object Brief Caption
// Web Object Story Attributes
  Title     : string;    // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  UDWLayout : TN_UDBase; // Windows Layout
  UDWWinObj : TN_UDBase; // Start Window Object
end; //*** end of type TK_MVWebVTreeWin = record
type TK_PMVWebVTreeWin = ^TK_MVWebVTreeWin;

type TK_UDMVWVTreeWin = class( TK_UDMVWBase ) //*** WEB Structure Window UDBase
  constructor Create; override;
  function  CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function  AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
end; //*** end of type TK_UDMVWVTreeWin = class( TK_UDMVWBase )

type TK_MVWebSection = packed record //  MV Web Client Interface MultiSection Object Element Attributes
  Caption  : String;            // Section Caption
  WENType  : TK_MVWGECaptsType; // Section Elements Captions Type
  WECapts  : TK_RArray;         // Section Elements Captions - ArrayOf string
  ROrdVInd : Integer;           // Index of Vector for Ordering Section Table Rows
end; // type TK_MVWebSection = record
type TK_PMVWebSection = ^TK_MVWebSection;

type TK_MVWebMSTabWin = packed record // MV Web MultiSection Table Window
// Web Object Captions
  FullCapt  : string;   // Web Object Full Caption
  BriefCapt : string;   // Web Object Brief Caption
// Web Object Story Attributes
  Title     : string;   // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  VCSS      : TN_UDBase; // View CSS
  ASWENType : TK_MVWGECaptsType; // Added Sections Elements Captions Type
  SCType    : TK_MVWGECaptsType; // Sections Self Captions Type
  Sections  : TK_RArray; // Sections Attributes - ArrayOf TK_MVWebSection
  ElemCapts : TN_UDBase; // Reference to CS UDVector of String with Elements Captions
  CurSInd  : Integer;    // Cur Section Index for MS Word Documet Reperesantation
end; // type TK_MVWebMSTabWin = record
type TK_PMVWebMSTabWin = ^TK_MVWebMSTabWin;

type TK_UDMVWMSTabWin = class( TK_UDMVWBase ) //*** Web MultiSection Table Window UDBase
  function  CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function  AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
  function  DeleteSubTreeChild( Index : Integer ) : Boolean; override;
  procedure MoveSubTreeChilds( dInd, sInd: Integer; mcount : Integer = 1 ); override;
  function  CanAddOwnChildByPar( CreatePar : Integer = 0 ): Boolean; override;
end; //*** end of type TK_UDMVWMSTabWin = class( TK_UDMVWBase )

type TK_MVWLDShowFlags0 = Set Of ( //*** Diagram Show Flags
         K_dsfSelElem, {= "Отображать список выбора элементов данных"}
         K_dsfSkipSelColCtrl {= 'Запрет генерации события  "Выбор столбца таблицы"'} );

type TK_MVWLDShowFlags = packed record
    case Integer of
      0: ( T : TK_MVWLDShowFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVWLDShowFlags = record

type TK_MVWebLDiagramWin = packed record //*** MV Web Line Diagram Window (*TK_UDMVWLDiagramWin*)
// Web Object Captions
  FullCapt  : string;   // Web Object Full Caption
  BriefCapt : string;   // Web Object Brief Caption
// Web Object Story Attributes
  Title     : string;   // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  VCSS      : TN_UDBase; // View CSS
  ASWENType : TK_MVWGECaptsType; // Added Sections Elements Captions Type
  SCType    : TK_MVWGECaptsType; // Sections Self Captions Type
  Sections  : TK_RArray; // Sections Attributes - ArrayOf TK_MVWebSection
  ElemCapts : TN_UDBase; // Reference to CS UDVector of String with Elements Captions
  CurSInd  : Integer;    // Cur Section Index for MS Word Documet Reperesantation
// end of TK_MVWebMSTabWin
//...
  ShowFlags : TK_MVWLDShowFlags; // Diagram Show Flags
//  CSProj    : TN_UDBase; // CS Projection For Table Row Relations Setting
  CSProj1    : TN_UDBase; // CS Projection For Table Row Relations Setting // CSProj was changed to CSProj1 to find all Usings of this field
  PECSS     : TN_UDBase; // CSS defines Elements shown Permanently in Diagram
  CRCSS     : TN_UDBase; // CSS defines Elements Order for Cross References Table in Word Doc Diagram
  LegHeader : string;    // Histogram Legend Header - Column with Data Header
end; // type TK_MVWebLDiagramWin = record
type TK_PMVWebLDiagramWin = ^TK_MVWebLDiagramWin;

type TK_UDMVWLDiagramWin = class( TK_UDMVWMSTabWin ) //*** Web Line Diagram Window UDBase
  constructor Create; override;
end; //*** end of type TK_UDMVWLDiagramWin = class( TK_UDMVWMSTabWin )

type TK_MVWLTShowFlags0 = Set Of ( //*** Table Show Flags
         K_tsfSkipSelColCtrl {= "Запрет отображения кнопки выбора столбца"} );

type TK_MVWLTShowFlags = packed record
    case Integer of
      0: ( T : TK_MVWLTShowFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVWLDShowFlags = record

type TK_MVWebTableWin = packed record  //*** WEB Table Window (*TK_UDMVWTableWin*)
// Web Object Captions
  FullCapt  : string;   // Web Object Full Caption
  BriefCapt : string;   // Web Object Brief Caption
// Web Object Story Attributes
  Title     : string;   // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  VCSS      : TN_UDBase; // View CSS
  ASWENType : TK_MVWGECaptsType; // Added Sections Elements Captions Type
  SCType    : TK_MVWGECaptsType; // Sections Self Captions Type
  Sections  : TK_RArray; // Sections Attributes - ArrayOf TK_MVWebSection
  ElemCapts : TN_UDBase; // Reference to CS UDVector of String with Elements Captions
  CurSInd  : Integer;    // Cur Section Index for MS Word Documet Reperesantation
// end of TK_MVWebMSTabWin
  ShowFlags : TK_MVWLTShowFlags; // Table Show Flags
  SCSS      : TN_UDBase; // Special Rows CSS - To Use Special View Attributes For SomeTable Rows
  SHCaption : string; // Sidehead Caption
  DCSProjs  : TK_RArray; // ArrayOf TN_UDBase - Rows Structure - Set of DCSProjections
end; //*** end of type TK_MVWebTableWin = record
type TK_PMVWebTableWin = ^TK_MVWebTableWin;

type TK_UDMVWTableWin = class( TK_UDMVWMSTabWin ) //*** Web Line Diagram Window UDBase
  constructor Create; override;
end; //*** end of type TK_UDMVWTableWin = class( TK_UDMVWMSTabWin )

type TK_MVWebWinGroupElem = packed record //  MV Web Client Interface Group Element
  EERGName  : string; // Element Events Recipient Group Name
  EVWinName : string; // Element Web Client Interface Window Description Name
end; // type TK_MVWebWinGroupElem = record
type TK_PMVWebWinGroupElem = ^TK_MVWebWinGroupElem;

type TK_MVWebWinGroup = packed record //*** MV Web Windows Group (*TK_UDMVWWinGroup*)
// Web Object Captions
  FullCapt  : string;   // Web Object Full Caption
  BriefCapt : string;   // Web Object Brief Caption
// Web Object Story Attributes
  Title      : string;  // Window Title
  TVWinName  : string;  // Title Web Client Interface Window Description Name
  WGEAttribs : TK_RArray; // MV Web Windows Group Elements Attributes - ArrayOf TK_MVWebWinGroupElem
  AddMSWParsList : string;// Additional Params for MS Word Document Creation
end; // type TK_MVWebWinGroup = record
type TK_PMVWebWinGroup = ^TK_MVWebWinGroup;

type TK_UDMVWWinGroup = class( TK_UDMVWBase ) //*** Web Windows Group UDBase
  constructor Create; override;
  function  CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function  AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
  function  DeleteSubTreeChild( Index : Integer ) : Boolean; override;
  procedure MoveSubTreeChilds( dInd, sInd: Integer; mcount : Integer = 1 ); override;
end; //*** end of type TK_UDMVWWinGroup = class( TK_UDMVWBase )

type TK_MVWebHTMWin = packed record //*** MV Web HTML Text Window (*TK_UDMVWHTMWin*)
// Web Object Captions
  FullCapt  : string;   // Web Object Object Caption
  BriefCapt : string;   // Web Object Object Caption
// Web Object Story Attributes
  Title     : string;    // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  HTMText   : string;    // HTM Text
end; // type TK_MVWebHTMWin = record
type TK_PMVWebHTMWin = ^TK_MVWebHTMWin;

type TK_MVWebHTMRefWin = packed record //*** MV Web HTML File Window (*TK_UDMVWHTMWin*)
// Web Object Captions
  FullCapt  : string;   // Web Object Object Caption
  BriefCapt : string;   // Web Object Object Caption
// Web Object Story Attributes
  Title     : string;    // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  RHTMPath  : string;    // Relative Path to HTM file
end; // type TK_MVWebHTMRefWin = record
type TK_PMVWebHTMRefWin = ^TK_MVWebHTMRefWin;

type TK_UDMVWHTMWin  = class( TK_UDMVWBase ) //*** Web HTML Window UDBase
      public
  constructor Create; override;
end; //*** end of type TK_UDMVWHTMWin  = class( TK_UDMVWBase )

type TK_MVWebVHTMWin = packed record //*** MV Web HTML Texts Vector (*TK_UDMVWVHTMWin*)
  D        : TK_RArray; // HTM Text Parts - ArrayOf String
  CSS      : TN_UDBase; // Code SubSpace Reference
// end of TK_DSSVector
// start of TK_MVWebWinObj
// Web Object Captions
  FullCapt  : string;   // Web Object Object Caption
  BriefCapt : string;   // Web Object Object Caption
// Web Object Story Attributes
  Title     : string;    // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  StartEInd : Integer;   // Index of Start Vector Element
end; // type TK_MVWebVHTMWin = record

type TK_MVWebVHTMRefWin = packed record //*** MV Web HTML Files Vector (*TK_UDMVWVHTMWin*)
  D        : TK_RArray; // HTM References - ArrayOf String
  CSS      : TN_UDBase; // Code SubSpace Reference
// end of TK_DSSVector
// start of TK_MVWebWinObj
  FullCapt  : string;   // Web Object Object Caption
  BriefCapt : string;   // Web Object Object Caption
// Web Object Story Attributes
  Title     : string;    // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj
  StartEInd : Integer;   // Index of Start Vector Element
end; // type TK_MVWebVHTMRefWin = record
type TK_PMVWebVHTMWin = ^TK_MVWebVHTMWin;

type TK_UDMVWVHTMWin  = class( TK_UDVector ) //*** Web HTML Vector Window UDBase
      public
  constructor Create; override;
  function  RemoveSelfFromSubTree( PDE : TK_PDirEntryPar ) : Boolean; override;
end; //*** end of type TK_UDMVWVHTMWin  = class( TK_UDRArray )

type TK_MVMSWDAttrs = packed record //*** MS Word Document One Level Fragment Attributes  (*TK_UDMVMSWDAttrs*)
  UDWDTitle    : TN_UDBase; // Document Title TN_UDWordFragm
  UDWDTopic    : TN_UDBase; // Document Level Topic TN_UDWordFragm
  UDWDSpecTopic: TN_UDBase; // Document Level SpecTopic (Topic and SubTopic) TN_UDWordFragm
  UDWDSubTopic : TN_UDBase; // Document Level SubTopic TN_UDWordFragm
  UDWDQuestion : TN_UDBase; // Document Level Question TN_UDWordFragm
  UDWDMap      : TN_UDBase; // Document Level Map TN_UDWordFragm
  STopicNumber : Integer;   // Document Start Topic Number
  ResDocFName  : string;    // Document File Name
  ResDocCreateFlags : TN_EPExecFlags; // Document Creation Flags
end; // type TK_MVMSWDAttrs = record
type TK_PMVMSWDAttrs = ^TK_MVMSWDAttrs;

type TK_MVMSWDVAttrs = packed record //*** MS Word Document Common Attributes
  UDWDTitle    : TN_UDBase; // Document Title (Root) TN_UDWordFragm
  UDWDTopics   : TK_RArray; // Topics Levels  Array of TN_UDWordFragm (ArrayOf TN_UDBase)
  UDWDGroup    : TN_UDBase; // Group Level TN_UDWordFragm
  UDWDMapsGroup: TN_UDBase; // Maps Group Level TN_UDWordFragm
// Document Map for Vector
  UDWDMap      : TN_UDBase; // Map Level - Component or TN_UDWordFragm
  MapSEHUDCList: TK_RArray; // Map Level - Show Hint Components (ArrayOf TN_UDBase)
  UDMapsListInd: Integer;   // Map Level - Component Index in DCSpace Representation Attributes MapsCList Field (0 or 1 - Portrait or Landscape)
                            // 0 and 1 Components in MapsCList are always current Portrait and Landscape Components
// Document MultiColumn Histogram for Vectors Table
  UDWDHist     : TN_UDBase; // MultiColumn Histogram Level - Component or TN_UDWordFragm
  UDHistPars   : TN_UDBase; // MultiColumn Histogram Level - Params Component
  HistSEHUDCList: TK_RArray; // MultiColumn Histogram Level - Show Hint Compnents (ArrayOf TN_UDBase)
// Document Table  for Vectors Table
  UDWDTable    : TN_UDBase; // Table Level TN_UDWordFragm
  UDTablePars  : TN_UDBase; // Table Level Params Component
// Document Single Column Histogram for Vector
  UDWDMapHist  : TN_UDBase; // Single Column Histogram Level - Component or TN_UDWordFragm
  UDWDMapHistD : TN_UDBase; // Single Column Histogram Dynamic Level - Component or TN_UDWordFragm
  UDMapHistPars: TN_UDBase; // Single Column Histogram Level - Params Component
  MapHistSEHUDCList: TK_RArray; // Single Column Histogram Level - Show Hint Compnents (ArrayOf TN_UDBase)
// Document AutoGrouped Histograms for Vectors Table SubMatrix
  UDAGHist        : TN_UDBase; // Component
  UDAGHistPars    : TN_UDBase; // Params Component
  AGHisSEHUDCList : TK_RArray; // Show Hint Compnents (ArrayOf TN_UDBase)
//  UDAGHistColors  : TN_UDBase; // Different Colors Component
  UDAGHistRAColors: TK_RArray; // ColorSets (ArrayOf TN_UDBase)
  ResDocCreateFlags : TN_EPExecFlags; // Document Creation Flags
end; // type TK_MVMSWDVAttrs = record
type TK_PMVMSWDVAttrs = ^TK_MVMSWDVAttrs;
{
type TK_MVMSWDIAttrs = packed record //*** MS Word Document Individual Attributes
  ResDocFName  : string;    // Document File Name
  STopicNumber : Integer;   // Document Start Topic Number
end; // type TK_MVMSWDIAttrs = record
type TK_PMVMSWDIAttrs = ^TK_MVMSWDIAttrs;
}

type TK_MVWebSite = packed record //*** MV Web Site (*TK_UDMVWSite*)
  UDWLayout : TN_UDBase; // MV Web Client Windows Layout Object
  UDWWinObj : TN_UDBase; // Start Window Object
  RRootPath : string;    // Relative Path to Site Root Folder
// MS Word Document Individual Attributes -> TK_MVMSWDIAttrs
  ResDocFName  : string;    // Document File Name
  STopicNumber : Integer;   // Document Start Topic Number
// end of TK_MVMSWDIAttrs
// obsolete  MSWDAttrs    : TK_MVMSWDAttrs; // MV MS Word Document Attributes
  MSWDVAttrs   : TObject;   // MV MS Word Document Attributes
// Web Object Story Attributes
  Title     : string;    // Window Title
  Scripts   : TK_RArray; // Event Handler Scripts - ArrayOf TK_MVWebScript
  VWinName  : string;    // Virtual Window Name for WebVTree
  ERGName   : string;    // Events Recipient Group for WebVTree
end; // type TK_MVWebSite = record
type TK_PMVWebSite = ^TK_MVWebSite;

type TK_UDMVWSite  = class( TK_UDMVWBase ) //*** MV Web Site UDBase
      public
  constructor Create; override;
  function  CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function  AddChildToSubTree( PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ): Boolean; override;
end; //*** end of type TK_UDMVWSite  = class( TK_UDMVWBase )

//*** end of Web Objects

//********************************
// MV Vectors Data Containers
//********************************

type TK_TimePeriodType = (
         K_tptYear,    // = "год"
         K_tptHYear,   // = "полугодие"
         K_tptQuarter, // = "квартал"
         K_tptMonth,   // = "месяц"
         K_tpt10Days,  // = "декада"
         K_tptWeek,    // = "неделя"
         K_tptDay,     // = "день"
         K_tptHour,    // = "час"
         K_tptMinute,  // = "минута"
         K_tptSecond,  // = "секунда"
         K_tptMSecond  // = "миллисекунда"
       );

type TK_MVTimePeriod = packed record // TK_MVTimePeriod
  SDate     : TDateTime; // Start Date
  PLength   : Integer;   // Period Length
  case Integer of        // Period Type
  0 : ( PType     : TK_TimePeriodType; );
  1 : ( IEnum     : Integer; );
end; // type TK_MVTimePeriod = record

type TK_MVVector = packed record //*** MVVector (*TK_UDMVVector*) from TK_DSSVector
  D        : TK_RArray;
  CSS      : TN_UDBase; // Code SubSpace Reference
// end of TK_DSSVector
  FullCapt : string;   // Vector full name
  BriefCapt: string;   // Vector brief name
  Units    : string;   // Units
  TimePeriod: TK_MVTimePeriod; // Vector Time Period
end; // type TK_MVVector = record
type TK_PMVVector = ^TK_MVVector;

type TK_UDMVVector  = class( TK_UDVector ) //*** Data Vector UDBase
      public
  constructor Create; override;
  function  RemoveSelfFromSubTree( PDE : TK_PDirEntryPar ) : Boolean; override;
  function  GetSubTreeParent( const DE : TN_DirEntryPar ): TN_UDBase; override;
end; //*** end of type TK_UDMVTable  = class( TK_UDRArray )

type TK_MVTable = packed record //*** MVVectors Table (*TK_UDMVTable*)
  FullCapt  : string;   // Table full defined name
  BriefCapt : string;   // Table brief name
  Comment   : string;   // Table data comment
  ElemCapts : TN_UDBase; // Reference to CS UDVector of String with Elements Captions
  AAnESCSS  : TK_RArray; // Array of CSS - each CSS specifies Analyzable Elements Set  - Arrayof TN_UDBase
end; // type TK_MVTable = record
type TK_PMVTable = ^TK_MVTable;

type TK_UDMVTable  = class( TK_UDRArray ) //*** Data Table Root UDBase
  constructor Create; override;
  procedure Init( UDCSSpace : TN_UDBase );
  function  CreateColumn( Aliase : string = ''; Name : string = '';
                                  AttrsNum : Integer = 1 ) : Integer;
  procedure InitColAttribs( Ind : Integer = -1;
                ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil );
  function  CreateMVVector( Name : string ) : TN_UDBase;
  function  CreateMVAttribs( Name : string; AttrsNum : Integer = 1 ) : TN_UDBase;
  function  CanMoveChilds : Boolean; override;
  function  CanMoveDE( const DE : TN_DirEntryPar ): Boolean; override;
  function  CanAddChildByPar( AddPar : Integer ) : Boolean; override;
  function  AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean; override;
  function  RemoveSelfFromSubTree( PDE : TK_PDirEntryPar ) : Boolean; override;
  procedure MoveSubTreeChilds( dInd, sInd: Integer; mcount : Integer = 1 ); override;
  function  DeleteSubTreeChild( Ind : Integer ) : Boolean; override;
  function  GetSubTreeChildDE( Ind : Integer; out DE : TN_DirEntryPar ) : Boolean; override;
  function  GetSubTreeChildHigh : Integer; override;
  function  GetUDAttribs( Ind : Integer ) : TK_UDRArray;
  function  GetUDVector( Ind : Integer ) : TK_UDVector;
  function  IndexOfUDVector( UDVector : TN_UDBase ) : Integer;
  function  GetUDVectorAllSufficientCaption( Ind : Integer ) : string;
end; //*** end of type TK_UDMVTable  = class( TK_UDRArray )

//*** end of MV Vectors Data Containers


//********************************
// MV Vectors View Attributes
//********************************

type TK_MVAutoManualType0 = (
         K_aumAuto,  // = "Автоматическое"
         K_aumManual // = "Ручное"
          );
type TK_PMVAutoManualType = ^TK_MVAutoManualType0;
type TK_MVAutoManualType = packed record   //***** TK_MVAutoManualType0
    case Integer of
      0: ( T : TK_MVAutoManualType0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVAutoManualType = record

type TK_MVValToTextPatType0 = (
         K_vttAuto,      // = "Автоматически" Pattern Auto Detect
         K_vttNameValue, // = "Название+значение" Name+Value
         K_vttNameRange, // = "Название+ранг" Name+Range
         K_vttName,      // = "Название" Name
         K_vttRange,     // = "Ранг" Range
         K_vttValue,     // = "Значение" Value
         K_vttUValue,    // = "Значение+Единицы" UValue
         K_vttManual     // = "Вручную" Manual
          );
type TK_PMVValToTextPatType = ^TK_MVValToTextPatType0;
type TK_MVValToTextPatType = packed record   //***** TK_MVValToTextPatType0
    case Integer of
      0: ( T : TK_MVValToTextPatType0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVValToTextPatType = record

type TK_MVAutoRangeType0 = (
         K_artEqualNElems, // Equal Elements Number Intervals
         K_artOptimal,     // Optimal Intervals
         K_artEqualStep,   // Equal Size Intervals
//       K_artEqualSize    // Equal Size Intervals
         K_artWAverage4,   // 4 weighted average Intervals
         K_artBestWorst10, // 10 the best and 10 the worst !!! Temporary not Used
         K_artStdDev123    // Standard Deviation Intervals
          );
type TK_PMVAutoRangeType = ^TK_MVAutoRangeType0;
type TK_MVAutoRangeType = packed record   //***** Auto Range Builder Type
    case Integer of
      0: ( T : TK_MVAutoRangeType0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_AutoRangeType = record

type TK_MVValuesDistType0 = (
         K_vdtContinuous,   // = "Непрерывные значения" Continuous Values
         K_vdtDiscrete      // = "Дискретные значения" Discrete Values
          );
type TK_PMVValuesDistType = ^TK_MVValuesDistType0;
type TK_MVValuesDistType = packed record   //***** Values Distribution Type
    case Integer of
      0: ( T : TK_MVValuesDistType0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVValuesDistType = record

type TK_MVColorConvType0 = (
         K_cctByRange,     // = "По классу" Color Conversion by Range
         K_cctByValue,     // = "По значению" Color Conversion by Value
         K_cctNoConvertion // = "Не используется" Manual Color Definition
          );
type TK_MVColorConvType = packed record   //***** Values Distribution Type
    case Integer of
      0: ( T : TK_MVColorConvType0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVColorConvType = record

type TK_MVColorsOrderType0 = (
         K_cotDirect,   // = "Прямая цветовая шкала" Direct Colors Order
         K_cotIndirect  // = "Обратная цветовая шкала" Indirect Colors Order
          );
type TK_MVColorsOrderType = packed record   //***** Values Distribution Type
    case Integer of
      0: ( T : TK_MVColorsOrderType0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVColorsOrderType = record

type TK_MVSVLegendShowFlags0 = set of (
         K_svlAlways, // = 'Показывать всегда' Show Always
         K_svlAfter   // = 'Показывать в конце' Show After Main Scale
          );
type TK_PMVSVLegendShowFlags = ^TK_MVSVLegendShowFlags0;
type TK_MVSVLegendShowFlags = packed record   //*** Special Values Legend Show Flags
    case Integer of
      0: ( T : TK_MVSVLegendShowFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVSVLegendShowFlags = record

type TK_MVLinHistShowFlags0 = set of (
         K_lhsSVSkipBar, // = исключать для специальных значений столбики
         K_lhsSVSkipAll  // = исключать для специальных  и столбики и перекрестные ссылки
          );
type TK_PMVLinHistShowFlags = ^TK_MVLinHistShowFlags0;
type TK_MVLinHistShowFlags = packed record   //*** LinHist Show Flags
    case Integer of
      0: ( T : TK_MVLinHistShowFlags0; );
      1: ( R  : Integer;  );
end; //*** end of type TK_MVLinHistShowFlags0 = record

type TK_MVVAttrs = packed record // MVVector Main Values View Attributes
  AnSECSS    : TN_UDBase; // Analyzable Set of Elements - CSS
// Value to Range attributes
  AutoRangeVals  : TK_MVAutoManualType; // Auto Range Bounds Building by Scale Values Attribute (=0 Auto)
  ValueType : TK_MVValuesDistType;
  RangeValues    : TK_RArray; // Range Bounds   - ArrayOf Double
  RangeCaptions  : TK_RArray; // Range Captions - ArrayOf String
  AutoRangeType : TK_MVAutoRangeType; //* Auto Range Builder Type
  RangeCount  : Integer;            //* Ranges Count
  RDPPos : Integer;            //* Number of Decimal Signs after decimal point in Range Bound
  RFormat : string;            // Range Value to String Format
  AutoRangeCapts : TK_MVAutoManualType; //* Auto Range Captions Build Mode (=0 Auto)
  AutoCaptsFormat : TK_RArray; //* Auto Range Captions Build Patterns - ArrayOf string [0..2] - ArrayOf String
//  Color Building attributes
  BuildColorsType  : TK_MVColorConvType; // Auto Scale Step Names Building by Scale Values Attribute (=0 Auto)
//  ColorsSet   : TN_UDBase; // Reference to UDRarrayOf Color
  ColorsSet    : TObject;   // Reference to VArrayOf Color
  ColorSchemes : TK_RArray; // ArrayOf UDRarrayOf Color
  ColorsSetOrder : TK_MVColorsOrderType; // Colors set Order
  RangeColors : TK_RArray; // Range to Color correspondence - ArrayOf Color
// Elements Captions
  ElemCapts : TN_UDBase; // Reference to CS UDVector of String with Elements Captions
// Num Value to Text
  VDPPos     : Integer;  // Number of Decimal Signs after decimal point in vector values
  VFormat    : string;   // Value to String Format
// Pure Value to Text
  PureValPatType : TK_MVValToTextPatType;
  PureValToTextPat : String; // Pure Vector Value to Text Pattern (+(Data Value or Range Value)+)
// Named Value to Text
  NamedValPatType : TK_MVValToTextPatType;
  NamedValToTextPat : String; // Named Vector Value to Text Pattern (+(Name)+(Data Value or Range Value)+)
// Value Convertion to Dimensionless Value
  AutoMinMax : TK_MVAutoManualType; // Auto Min/Max Calculating (=0 Auto)
  VMin   : Double; // Vector Value Min - Dimensionless Value 0
  VMax   : Double; // Vector Value Max - Dimensionless Value 100
  VBase  : Double; // Vector Value Base
  VDConv : TK_RArray; // Vector Value to Dimensionless Value Convertion Linearity - ArrayOf Double
// Special Values Attributes
  AbsDCSESVIndex : Integer; // Index of Special Value for Initialising Values when convert this Vector to Larger Vector
  UDSVAttrs : TN_UDBase; // Reference to UDRArray with Special Values Convertion Attributes
// Histogram Axis Attributes
  AutoAxisTicks : TK_MVAutoManualType; // Auto Histogram Axis Tick Step Calculating (=0 Auto)
  AxisTickStep   : Double;  // Resulting Axis Tick Step in Value Units
  AxisMarkText   : string;  // Resulting Axis Mark
  AxisTickFormat : string;  // Resulting Axis Tick Mark Format
  AxisCharLength : Integer; // Axis Approximate Length in Mark Chars
  AxisTickUnits  : string;  // Axis Tick Mark Units
// Regions Visibility CSS
  UDURegVisCSS   : TN_UDBase; // Reference to CSS with visible United Regions
// AutoRangeVals Calculation Additional Attributes
  AutoRangeCSS   : TN_UDBase; // AutoRangeVals Calculation Elements Restriction CSS (needed to exclude some vector elements while Scale Range Values Calculation is done)
  AutoRangeWData : TN_UDBase; // Weighting Vector for Average Scale Ranges Calculation
// Additional data vector for LinHist (results of compare with previous period)
  AddLHDataVector: TK_RArray; // ArrayOf TK_MVVector
  LHShowFlags    : TK_MVLinHistShowFlags; // LinHist Show Flags Set
end; // type TK_MVVAttrs = record
type TK_PMVVAttrs = ^TK_MVVAttrs;
//*** end of MV Vectors View Attributes

//********************************
// MV Representations Commmon Params
//********************************

type TK_MVRVAComAttrs = packed record // MV Representations Common Vector Attributes
// Value to Range attributes
  AutoRangeVals  : TK_MVAutoManualType; // Auto Range Bounds Building by Scale Values Attribute (=0 Auto)
  ValueType : TK_MVValuesDistType;
  AutoRangeType : TK_MVAutoRangeType; //* Auto Range Builder Type
  RangeCount  : Integer;            //* Ranges Count
  RDPPos : Integer;            //* Number of Decimal Signs after decimal point in Range Bound
  RFormat : string;            // Range Value to String Format
  AutoRangeCapts : TK_MVAutoManualType; //* Auto Range Captions Build Mode (=0 Auto)
  AutoCaptsFormat : TK_RArray; //* Auto Range Captions Build Patterns - ArrayOf string [0..2] - ArrayOf String
//  Color Building attributes
  BuildColorsType  : TK_MVColorConvType; // Auto Scale Step Names Building by Scale Values Attribute (=0 Auto)
  ColorsSet   : TObject;     // Reference to VArrayOf Color
  ColorSchemes : TK_RArray; // ArrayOf UDRarrayOf Color
//  ColorsSet   : TN_UDBase; // Reference to UDRarrayOf Color
  ColorsSetOrder : TK_MVColorsOrderType; // Colors set Order
// Num Value to Text
  VDPPos     : Integer;  // Number of Decimal Signs after decimal point in vector values
  VFormat    : string;   // Value to String Format
// Pure Value to Text
  PureValPatType : TK_MVValToTextPatType;
  PureValToTextPat : String; // Pure Vector Value to Text Pattern (+(Data Value or Range Value)+)
// Named Value to Text
  NamedValPatType : TK_MVValToTextPatType;
  NamedValToTextPat : String; // Named Vector Value to Text Pattern (+(Name)+(Data Value or Range Value)+)
// Special Values Attributes
  AbsDCSESVIndex : Integer; // Index of Special Value for Initialising Values when convert this Vector to Larger Vector
  UDSVAttrs : TN_UDBase; // Reference to UDRArray with Special Values Convertion Attributes
end; // type TK_MVRComAttrs = packed record
type TK_PMVRVAComAttrs = ^TK_MVRVAComAttrs;

type TK_MVRWDComAttrs = packed record //*** MV Representations Web Line Diagram Common Attributes
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj Common pars
  ASWENType : TK_MVWGECaptsType; // Added Sections Elements Captions Type
  SCType    : TK_MVWGECaptsType; // Sections Self Captions Type
// end of TK_MVWebMSTabWin Common pars
  ShowFlags : TK_MVWLDShowFlags; // Diagram Show Flags
end; // type TK_MVRWDComAttrs = record
type TK_PMVRWDComAttrs = ^TK_MVRWDComAttrs;

type TK_MVRWTComAttrs = packed record  //*** MV Representations WEB Table Common Attributes
  VWinName  : string;    // Virtual Window Name
  ERGName   : string;    // Events Recipient Group Name
  WWFlags   : TK_MVWebWinFlags; // Web Object Mode Flag
// end of TK_MVWebWinObj Common pars
  ASWENType : TK_MVWGECaptsType; // Added Sections Elements Captions Type
  SCType    : TK_MVWGECaptsType; // Sections Self Captions Type
// end of TK_MVWebMSTabWin Common pars
  ShowFlags : TK_MVWLTShowFlags; // Table Show Flags
  SHCaption : string;    // Sidehead Caption
  ERAArray  : TK_RArray; // Abmodalities Array for Table Cells Highlighting (ArrayOf Double)
end; //*** end of type TK_MVRWTComAttrs = record
type TK_PMVRWTComAttrs = ^TK_MVRWTComAttrs;

type TK_MVRNCList = packed record //*** MV Representations Named Components List Element
  ListCaption : string;    // Component Caption
  UDComp    : TN_UDBase; // Component Root Node
  SEHUDCList: TK_RArray; // Show Component Elements Hint Objects List (ArrayOf TN_UDBase)
end; // type TK_MVRNCList = record
type TK_PMVRNCList = ^TK_MVRNCList;

type TK_MVRNCList2 = packed record //*** MV Representations Named Components List Element with Landscape and Portrait data
// For Default Interactive Show should be used Component with assigned SEHUDCList (<> nil) 
  ListCaption : string;    // Component Caption
// Portrait orientation
  UDCompPT    : TN_UDBase; // Component Root Node
  SEHUDCListPT: TK_RArray; // Show Component Elements Hint Objects List (ArrayOf TN_UDBase)
// Landscape orientation
  UDCompLS    : TN_UDBase; // Component Root Node
  SEHUDCListLS: TK_RArray; // Show Component Elements Hint Objects List (ArrayOf TN_UDBase)
  UDMLColorMask: TN_UDBase; // Map Main Layer Color Mask - for proper Hints Build
end; // type TK_MVRNCList = record
type TK_PMVRNCList2 = ^TK_MVRNCList2;

type TK_MVRExpComAttrs = packed record //*** MV Representations Export Common Attributes
  DWFCList    : TK_RArray; // Document Root Word Fragments List (ArrayOf TK_MVRNCList)
  UDCH1CAttrs : TN_UDBase; // Hist1C Component Attributes Node
  H1CCList    : TK_RArray; // Hist1C Components List (ArrayOf TK_MVRNCList)
  H1CCListD   : TK_RArray; // Hist1C Components List (ArrayOf TK_MVRNCList)
  UDCHNCAttrs : TN_UDBase; // HistNC Component Attributes Node
  HNCCList    : TK_RArray; // HistNC Components List (ArrayOf TK_MVRNCList)
  UDCTabAttrs : TN_UDBase; // Table Component Attributes Node
  TabCList    : TK_RArray; // Table Components List (ArrayOf TK_MVRNCList)
end; // type TK_MVRExpComAttrs = record
type TK_PMVRExpComAttrs = ^TK_MVRExpComAttrs;

type TK_MVRComAttrs = packed record // MV Representations Common Attributes
  VA : TK_MVRVAComAttrs;  // Vector Attribute Common Params
  WD : TK_MVRWDComAttrs;  // WEBLDiagram Common Params
  WT : TK_MVRWTComAttrs;  // WEBTable Common Params
  EP : TK_MVRExpComAttrs; // MS Word Export Common Attributes
end; // type TK_MVRComAttrs = packed record
type TK_PMVRComAttrs = ^TK_MVRComAttrs;

type TK_MVRCSAttrs = packed record // MV Representations Common Attributes Depended from CS
// Elements Captions
  RCSAElemCapts : TN_UDBase; // Reference to CS UDVector of String with Elements Captions
// WLDiagram Common Params
  RCSACSProj    : TN_UDBase; // CS Projection For Table Row Relations Setting
  RCSAPECSS     : TN_UDBase; // CSS defines Elements Shown Permanently in Diagram
  RCSACRCSS     : TN_UDBase; // CSS defines Elements Order for Cross References Table in Word Doc Diagram
// WTable Common Params
  RCSASCSS      : TN_UDBase; // Special Rows CSS - To Use Special View Attributes For Some Table Rows
  RCSADCSProjs  : TK_RArray; // Rows Structure - Set of DCSProjections (ArrayOf TN_UDBase)
  RCSAERAElemCode : string;  // Average Value Element CS Code
// Map Components List - obsolete
  MapCList    : TK_RArray;   // Map Components List (ArrayOf TK_MVRNCList) (2 elements>: 0 - Portrait, 1 - Landscape)
// Map Components New Control
  RCSAMapCListInd : Integer;   // Map Components List Current Index
  RCSAMapCList    : TK_RArray; // Map Components List (ArrayOf TK_MVRNCList2)
end; // type TK_MVRCSAttrs = packed record
type TK_PMVRCSAttrs = ^TK_MVRCSAttrs;

//*** end of MV Representations Commmon Params

//********************************
// MV 2D Representation
//********************************
type TK_DRPFlags = Set Of (
  K_drpVisible,      // = "Видимость плоскости",
  K_drpZColor,       // = "Закраска",
  K_drpAutoCaption,  // = "Автоназвание плоскости",
  K_drpShowECaption  // = "Отображение названия элементов",
//  K_drpAxisScaleBalance// = "Выравнивание масштаба по осям"
);

type TK_MVCorPictVector = packed record // MV CorPict Vector Description
  UDV  : TN_UDBase;  // UDVector Reference
  UDVA : TN_UDBase;  // UDVAttrs Reference
  VCaption : string; // Vector Caption
end;
type TK_PMVCorPictVector = ^TK_MVCorPictVector;

type TK_MVCorPictPlane = packed record // MV 2D Representation Plane attributes
  DRPFlags  : TK_DRPFlags; // Plane Flags
  DRPCaption : string;     // Plane Caption
  DRPLegCapt : string;     // Plane Legend Caption
  DRPVX : TK_MVCorPictVector;  // X Vector
  DRPVY : TK_MVCorPictVector;  // Y Vector
  DRPVZ : TK_MVCorPictVector;  // Z Vector
  DRVCSInds  : TK_RArray;  // CSInds of Elements which are show on the plane picture - ArrayOf Integer
  DRPSignInd : Integer;    // Sign Index
  DRPSSize   : TFPoint;    // Sign Size
  DRPSShift  : TFPoint;    // Sign Shift
  DRPSColor  : Integer;    // Sign Color
  DRPLHPoint : TFPoint;    // Label HotPoint
  DRPLShift  : TFPoint;    // Label Shift
  DRPLFont   : TK_RArray;  // Label Font ArrayOf TN_NFont
end;
type TK_PMVCorPictPlane = ^TK_MVCorPictPlane;

type TK_MVCorPictCFlags = Set Of (
  K_drcOverlapPlanes,      // = "Совмещение плоскостей",
  K_drcAutoCaption,        // = "Автоназвание представления",
  K_drcShowLegend,         // = "Показ легенды представления",
  K_drcAutoSign,           // = "Автовыбор знаков плоскостей",
  K_drcSkipSignsScale,     // = "Блокировка масштабирования знаков",
  K_drcPlanesScaleBalance, // = "Выравнивание масштаба по плоскостям",
//  K_drcUsePlanesMinMax,    // = "Использование заданных координатного пространства",
  K_drcManualPlanesScale,  // = "Использование заданных координат",
  K_drcAutoEnlargePictSize,// = "Автоувеличение изображения",
  K_drcSavePictAspect,     // = "Поддержание аспекта графика",
  K_drcAutoAxisCaption,    // = "Автоназвания осей графика",
  K_drcHeaderAboveGraph,   // = "Заголовок над графиком",
  K_drcShowTickLines,      // = "Разметка графика",
  K_drcShowDiagonal,       // = "Диагональ",
  K_drcShowQuadrants,      // = "Квадранты",
  K_drcGroupByValue        // = "Группировка по значению"
);

type TK_MVCorPict = packed record // MV Correlation Picture
  CPCFlags  : TK_MVCorPictCFlags; // Common Flags
  CPCaption       : string;      // Caption
  CPCaptPatSep    : string;      // Caption Pattern Separator
  CPXAxisCaption  : string;      // XAxis Caption
  CPYAxisCaption  : string;      // YAxis Caption
  CPXAxisPat      : string;      // XAxis Caption Pattern
  CPYAxisPat      : string;      // YAxis Caption Pattern
  CPPlaneXYPat    : string;      // Plane Caption Pattern without Z-vector
  CPPlaneXYZPat   : string;      // Plane Caption Pattern with Z-vector
  CPPlaneLegXYPat : string;      // Plane Legend Pattern without Z-vector
  CPPlaneLegXYZPat: string;      // Plane Legend Pattern with Z-vector
  CPEAliasesName  : string;      // UName of Plane XVector Elements Aliases UDVector
  CPPlanes        : TK_RArray;   // Planes - ArrayOf TK_MVCorPictPlane
  CPPlanesMinMax  : TFRect;      // Planes Coords Space
  CPSize          : TFPoint;     // CorPict Size in mm
  CPHShift        : TFPoint;     // Header Shift in mm
// obsolete CPGroupStep     : Double;      // Group Value Step
  CPGroupXYStep   : TFPoint;     // Group Value Step XY
//  VCSS         : TN_UDBase;   // View Vectors as Table CSS
// Add Element Captions Pos Attributes ???
end;
type TK_PMVCorPict = ^TK_MVCorPict;

type TK_UDMVCorPict  = class( TK_UDRArray ) //*** Correlation Picture UDBase
  constructor Create; override;
  procedure Init(); // create Vectors and Attributes UDRoots containers
  procedure MoveSubTreeChilds( dInd, sInd: Integer; mcount : Integer = 1 ); override;
  function  DeleteSubTreeChild( Ind : Integer ) : Boolean; override;
  function  GetSubTreeChildDE( Ind : Integer; out DE : TN_DirEntryPar ) : Boolean; override;
  function  GetSubTreeChildHigh : Integer; override;
  function  GetUDAttribs( Ind : Integer ) : TK_UDRArray;
  function  GetUDVector( Ind : Integer ) : TK_UDVector;
  function  IndexOfUDVector( UDVector : TN_UDBase ) : Integer;
end; //*** end of type TK_UDMVCorPict  = class( TK_UDMVTable )

var K_MVCorPictUDMVVectorFilterUDCS : TN_UDBase;
type TK_MVCorPictUDMVVectorFilterItem = class( TK_UDFilterItem ) //
  function    UDFITest( const DE : TN_DirEntryPar ) : Boolean;  override;
end; //*** end of type TK_MVCorPictUDMVVectorFilterItem = class( TK_UDFilterItem )

type TK_RAFMVCorPictUDMVVectorEditor = class( TK_RAFUDRefEditor1 ) //
  procedure  SetContext( const Data ); override;
  function Edit( var Data ) : Boolean; override;
end; //*** type TK_RAFMVCorPictUDMVVectorEditor = class( TK_RAFUDRefEditor )

//*** end of MV Correlation Picture common objects

//***************************************
// MV Vectors Data Edit Form Descriptions
//***************************************

type TK_MVDataSpecVal = packed record // MV Data Special Values
  IVNum   : Integer; // special value coefficient
  Value   : Double;  // special value
  Caption : string;  // value name
  Color   : Integer; // fill color
  DSValue : Double;  // Dimensionless Value
  LegShowFlags : TK_MVSVLegendShowFlags; // Legend Flags
  RIndex : Integer; // Index + 1 for Value to Range Index Conversion
end; // type TK_MVDataSpecVal = record
type TK_PMVDataSpecVal = ^TK_MVDataSpecVal;

type TK_RAFMVTabEditor = class( TK_RAFEditor1 ) // ***** Color Array Field Editor
  CmB : TComboBox;
  PData : PDouble;
  ECol, ERow : Integer;
  SVArr : TK_RArray;
  destructor Destroy; override;
  function   Edit( var Data ) : Boolean; override;
  procedure OnKeyDownH( Sender: TObject; var Key: Word; Shift: TShiftState );
  procedure OnExitH( Sender: TObject );
  procedure SetResult( );
end; //*** type TK_RAFMVTabEditor = class( TK_RAFEditor )

type TK_RAFMVTabViewer = class( TK_RAFViewer ) // ***** Base class for Records Array Field Viewer
  function  GetText( var Data; var RAFC : TK_RAFColumn; ACol, ARow : Integer;
                PHTextPos : Pointer = nil ): string; override;
end; //*** type TK_RAFColorViewer = class( TK_RAFViewer )

//*** end of MV Vectors Data Edit Form Descriptions

type TK_RAMVVWinNameEditor = class( TK_RAFUDRefEditor ) // ***** UDMVVWinName Editor
  constructor Create; override;
  function Edit( var Data ) : Boolean; override;
end; //*** type TK_RAMVVWinNameEditor = class( TK_RAFUDRefEditor )

type TK_SpecValsAssistant  = class //*** Spec Values Use Assistant
  PScale : PDouble;
  ScaleStep : Integer;
  ScaleHigh : Integer;
  RASV : TK_RArray;
  constructor Create( ARASV : TK_RArray );
  destructor Destroy; override;
  function  IndexOfSpecVal( Val : Double ) : Integer; overload;
  function  IndexOfSpecVal(Capt: string): Integer; overload;
  function  GetSpecValAttrs( ValInd : Integer ) : TK_PMVDataSpecVal;
  procedure GetSpecValStrings( SL : TStrings );
end; //*** end of type TK_SpecValsAssistant  = class
type TK_PSpecValsAssistant = ^TK_SpecValsAssistant;

type TK_MVValConv  = class //*** Spec Values Use Assistant
  MVVAttrs : TK_MVVAttrs;
  PMVVAttrs : TK_PMVVAttrs;
  PScale    : PDouble;
  ScaleHigh : Integer;
  SVA : TK_SpecValsAssistant;
  CVInd     : Integer;
  CVal      : Double;
  ML : TStringList;
//  constructor Create;
  constructor Create;
  destructor Destroy; override;
  procedure  SetUnits( Units : string );
  procedure  SetMVVAttrs( APMVVAttrs : TK_PMVVAttrs = nil );
  procedure RebuildMVAttribs( PData : PDouble; DStep, DCount : Integer;
               ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil;
               PIndex : PInteger = nil; ICount : Integer = 0 );
  procedure  SetCurValue( AVal : Double );
  function   GetValText( AValName : string = '' ) : string;
  function   GetNamedValText( AValName : string = '' ) : string;
  function   GetValColor : Integer;
end; //*** end of type TK_MVValConv  = class

type TK_ColorSchemeBuildFlags = Set of (
   K_csbfReverseResultOrder,     // "Обратный порядок цветов"
   K_csbfUniformPathPointWeight, // "Равномерный шаг по цветовому пути"
   K_csbfUsePathPoints           // "Использовать точки цветового пути"
   );

function  K_RemoveMVDarFolderElement( Folder : TN_UDBase; Index : Integer ) : Boolean;
procedure K_InitMVSpecValsList( SV : TK_RArray; SL : TStrings);
procedure K_InitMVSpecValues;
function  K_GetMVTableDType() : TK_ExprExtType;
function  K_GetSpecValueInd( DValue : Double; SVArr : TK_RArray ) : Integer; overload;
function  K_GetSpecValueInd( DValue : Double; UDSVArr : TN_UDBase ) : Integer; overload;
procedure K_GetSpecValStrings( SL : TStrings; SVArr : TK_RArray );
function  K_GetMVVectorNotSpecValues( PData : PDouble; DCount : Integer; SV : TK_RArray;
                                      PIndex : PInteger ) : TN_DArray;
function  K_BuildMVVectorNotSpecValuesIndex( PData : PDouble; PInd : PInteger; DCount : Integer ) : Integer;
function  K_MVDSum( PData : PDouble; DCount : Integer; PRCount : PInteger = nil ) : Double;

function  K_GetPRAColorScheme( ColorSchemes : TK_RArray;
                               ColorSchemeInd : Integer ) : TK_PRArray;
procedure K_BuildColorsByColorScheme( PRColors : PInteger; RCount : Integer;
                               ColorScheme : TK_RArray;
                               BuildFlags : TK_ColorSchemeBuildFlags = [] );
function  K_RebuildVectorMinMax( var VMin, VMax : Double; RecalcMinMax : Boolean;
                    PData : PDouble; DStep : Integer; DCount : Integer;
                    PIndex : PInteger = nil; ICount : Integer = 0;
                    IDColCount : Integer = 0 ) : TN_DArray;
procedure K_BuildAxisTicksAttrs( out AAxisTickStep : Double;
                                var AAxisCharLength : Integer;
                                APAxisTickFormat, APAxisMarkText : PString;
                                AVMin, AVMax : Double; AAxisTickUnits : string = '' );
procedure K_RebuildMVAttribs( var MVAttribs : TK_MVVAttrs; APMVVEctor : TK_PMVVector;
              ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil ); overload;
procedure K_RebuildMVAttribs( var MVAttribs : TK_MVVAttrs; VV : TK_RArray;
              ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil;
              PIndex : PInteger = nil; ICount : Integer = 0 ); overload;
procedure K_GetMVStandardValToTextPattern( var APat : string; APatType : TK_MVValToTextPatType0 );
procedure K_RebuildMVAttribs( var MVAttribs : TK_MVVAttrs;
                    PData : PDouble; DStep : Integer; DCount : Integer;
                    ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil;
                    PIndex : PInteger = nil; ICount : Integer = 0;
                    IDColCount : Integer = 0 ); overload;
procedure K_CopyMVAttribs( var DestMVAttribs : TK_MVVAttrs;
                           const SrcMVAttribs : TK_MVVAttrs );
procedure K_SetChildUniqNames( Parent, Child : TN_UDBase; ObjSysType : TK_MVDARSysType );
function  K_AddMVChildToSubTree( AParent : TN_UDBase; PDE : TK_PDirEntryPar;
       CopyPar : TK_CopySubTreeFlags; FolderObjSysType : TK_MVDARSysType = K_msdUndef ) : Boolean;
procedure K_BuildMVVElemsVAttribs( PData : PDouble; DCount : Integer;
                  PMVVAttrs : TK_PMVVAttrs;
                  PCSSInds : PInteger = nil;
                  PTextValues : PString = nil;
                  PNamedTextValues : PString = nil;
                  PColors : PInteger = nil;
                  PSWInds : Pointer = nil; PSVA : TK_PSpecValsAssistant = nil;
                  Units : string = '' );
function  K_IfShowCorPictPlane( PMVCorPictPlane : TK_PMVCorPictPlane;
                            ProcessInvisiblePlane : Boolean = false ) : Boolean;

var
  K_IniMVSpecVals : TK_RArray;
  K_CurMVSpecVals : TK_RArray;

  K_GroupRegDCSpace : TN_UDBase;
  K_GroupRegDCSInd  : Integer = -2; // because of ComboBox internal problems
  K_GroupRegDCSProj : TN_UDBase;
  K_GroupRegColor  : Integer = $FFFFFF;

implementation
uses
  Dialogs, SysUtils, Windows, Math,
  K_MVMap0, K_Arch, K_CLib0, K_VFunc, K_IndGlobal,
  K_UDConst, K_UDT2, K_FSelectUDB,
  N_Lib1;

var
  K_MVTableDType : TK_ExprExtType;

// CorPictUDMVVector Select Context
//  K_CPUDMVVMarkedList : TStringList; // Marked Nodes List
  K_CPUDMVVExpandedList : TStringList; // Expanded Nodes List


//***************************************** K_RemoveMVDarFolderElement
// Remove MVDar Folder Element
//
function  K_RemoveMVDarFolderElement( Folder : TN_UDBase; Index : Integer ) : Boolean;
var
  RCount : Integer;
  Child : TN_UDBase;
begin
  Result := false;
  if not Folder.DeleteSubTreeChild( -1 ) then begin
    if Folder.DeleteDirEntry( Index ) <> K_DRisOK then Exit;
  end else begin
    Child := Folder.DirChild(Index);
    Result := true;
    if Child.Owner = Folder then begin
      RCount := K_CurUserRoot.CountSubTreeReferences( Child );

      if (RCount <= 1) and (Child.RefCounter > RCount) then begin
      //*** Child is Used in Other Place
        Result := false;
        Exit;
      end;
      if RCount = 1 then Result := Child.SelfSubTreeRemove;
    end;
    if Result then
      Result := Folder.DeleteSubTreeChild(Index);
  end;
end; // end_of function K_RemoveMVDarFolderElement

//***************************************** K_InitMVSpecValsList
// Init MV SpecValues List
//
procedure K_InitMVSpecValsList( SV : TK_RArray; SL : TStrings);
var
  i : Integer;
  PSV : TK_PMVDataSpecVal;
begin
  if SV = nil then Exit;
  for i := 0 to SV.AHigh do begin
    PSV := TK_PMVDataSpecVal(SV.P(i));
    SL.AddObject( PSV.Caption, PObject(PSV)^ );
  end;
end; // end_of procedure K_InitMVSpecValsList

//***************************************** K_InitMVSpecValues
// Init Work Zone and Special values
//
procedure K_InitMVSpecValues;
var
  SectionList : TStringList;
  i : Integer;
  SectName : string;
  DType : TK_ExprExtType;
  PSV : TK_PMVDataSpecVal;
begin
  SectionList := TStringList.Create;
  SectName := 'DataSpecValues';
  if not N_CurMemIni.SectionExists( SectName ) then begin
    K_ShowMessage( 'В INI-файле отсутствует секция ' + SectName );
    Exit;
  end;
  N_CurMemIni.ReadSectionValues( SectName, SectionList );
  K_MVMinVal := N_CurMemIni.ReadFloat(SectName, SectionList.Names[0], NaN );
  K_MVMaxVal := N_CurMemIni.ReadFloat(SectName, SectionList.Names[1], NaN );
  DType := K_GetTypeCodeSafe('TK_MVDataSpecVal');
  K_IniMVSpecVals := TK_RArray.CreateByType( DType.All, SectionList.Count - 2 );
  for i := 2 to SectionList.Count - 1 do begin
    PSV := K_IniMVSpecVals.P(i-2);
    K_SPLValueFromString( PSV^, DType.All, SectionList.ValueFromIndex[i] );
  end;
  K_CurMVSpecVals := K_IniMVSpecVals;
  TK_SpecValsAssistant.Create(K_CurMVSpecVals).Free; // Prepare SpecValues
end; // end_of procedure K_InitMVSpecValues

//**************************************** K_GetSpecValueInd
//
//
function K_GetSpecValueInd( DValue : Double; UDSVArr : TN_UDBase ) : Integer;
begin
  Result := -1;
  if (UDSVArr = nil)               or
      not (UDSVArr is TK_UDRArray) or
      (TK_UDRArray(UDSVArr).R.ElemType.All <> K_GetTypeCodeSafe('TK_MVDataSpecVal').All) then Exit;
  Result := K_GetSpecValueInd( DValue, TK_UDRArray(UDSVArr).R );
end; //*** function K_GetSpecValueInd

//**************************************** K_GetSpecValueInd
//
//
function K_GetSpecValueInd( DValue : Double; SVArr : TK_RArray ) : Integer;
var
  i : Integer;
//  h : Integer;
begin
  Result := -1;
  if ( (K_MVMinVal <= DValue) and
       (DValue <= K_MVMaxVal) ) or
     (SVArr = nil) then  Exit;
  i := K_IndexOfDoubleInScale( @(TK_PMVDataSpecVal(SVArr.P).Value), SVArr.AHigh, SVArr.ElemSize, DValue ) - 1;
  if (i >= 0) and (TK_PMVDataSpecVal(SVArr.P(i)).Value = DValue) then Result := i;
end; //*** function K_GetSpecValueInd

//**************************************** K_GetSpecValueInd
//
//
procedure K_GetSpecValStrings( SL : TStrings; SVArr : TK_RArray );
var
  i : Integer;
begin
  SL.Clear;
  for i := 0 to SVArr.Ahigh do
    SL.Add( TK_PMVDataSpecVal(SVArr.P(i)).Caption );
end; //*** end of K_GetSpecValStrings

//**************************************** K_AddSpecValue
//
//
function K_AddSpecValue( UDSVArr : TN_UDBase; ACaption : string;
        AColor : Integer = 0; ALegShowFlags : Integer = 0;
        ADValue : Double = 0; AIndex : Integer = 0 ) : Integer;
begin
  Result := -1;
  if (UDSVArr = nil)               or
      not (UDSVArr is TK_UDRArray) or
      (TK_UDRArray(UDSVArr).R.ElemType.All <> K_GetTypeCodeSafe('TK_MVDataSpecVal').All) then Exit;

  with TK_UDRArray(UDSVArr).R do begin
    Result := ALength;
    ASetLength( Result + 1 );
    with TK_PMVDataSpecVal( P(Result) )^ do begin
      Value   := K_MVMaxVal * Result;
      Caption := ACaption;
      Color   := AColor;
      LegShowFlags.R := ALegShowFlags;
      DSValue := ADValue;
      RIndex := AIndex;
    end;
  end;
end; //*** function K_AddSpecValue

//***************************************** K_GetMVVectorNotSpecValues
// Return Array of not Special Values
//
function K_GetMVVectorNotSpecValues( PData : PDouble; DCount : Integer;
                                     SV : TK_RArray; PIndex : PInteger ) : TN_DArray;
var
  i, j : Integer;
  PCurIndex : PInteger;
begin
  SetLength( Result, DCount );
  j := 0;
  Dec(DCount);
  PCurIndex := PIndex;
  for i := 0 to DCount do begin
//    if K_GetSpecValueInd( PV^, SV ) = -1 then begin
    if (PData^ < K_MVMaxVal) and (PData^ > K_MVMinVal) then begin
      if PIndex <> nil then
      begin
        PCurIndex^ := PIndex^;
        Inc(PCurIndex);
      end;
      Result[j] := PData^;
      Inc(j);
    end;
    Inc(PData);
    if PIndex <> nil then
      Inc(PIndex);
  end;
  SetLength( Result, j );
end; // end_of function K_GetMVVectorNotSpecValues

//***************************************** K_BuildMVVectorNotSpecValuesIndex
// Build Not SpecValues Index
//
function K_BuildMVVectorNotSpecValuesIndex( PData : PDouble; PInd : PInteger; DCount : Integer ) : Integer;
var
  i : Integer;
begin
  Result := 0;
  Dec(DCount);
  for i := 0 to DCount do begin
    if (PData^ < K_MVMaxVal) and (PData^ > K_MVMinVal) then begin
      PInd^ := i;
      Inc(PInd);
      Inc(Result);
    end;
    Inc(PData);
  end;
end; // end_of function K_BuildMVVectorNotSpecValuesIndex

//***************************************** K_MVDSum
// Return Sum of Doubles
//
function K_MVDSum( PData : PDouble; DCount : Integer; PRCount : PInteger = nil ) : Double;
var
  i, j : Integer;
begin

  j := 0;
  Result := 0;
  for i := 0 to DCount - 1 do begin
    if (PData^ < K_MVMaxVal) and (PData^ > K_MVMinVal) then begin
      Result := Result + PData^;
      Inc(j);
    end;
    Inc(PData);
  end;
  if PRCount <> nil then PRCount^ := j;

end; // end_of function K_MVDSum

//***************************************** K_GetPRAColorScheme
//
function K_GetPRAColorScheme( ColorSchemes : TK_RArray;
                               ColorSchemeInd : Integer ) : TK_PRArray;
var
  ColorUDSet : TK_UDRArray;
begin
  Result := nil;
  if ColorSchemes.ALength <= 0 then Exit;
  if ColorSchemeInd = -1 then ColorSchemeInd := 0;
  ColorUDSet := TK_UDRarray(TN_PUDBase(ColorSchemes.PS( ColorSchemeInd ))^);
  if (ColorUDSet <> nil) then Result := @ColorUDSet.R;
end; // end_of procedure K_GetPRAColorScheme

//***************************************** K_BuildColorsByColorScheme
//
procedure K_BuildColorsByColorScheme( PRColors : PInteger; RCount : Integer;
                               ColorScheme : TK_RArray;
                               BuildFlags : TK_ColorSchemeBuildFlags = [] );
var
  CPCount : Integer;
  UniformPathPointWeight : Boolean;
  PCSColors : Pointer;
  CurPathLeng : Integer;
  FullPathLeng : Integer;
  PathLeng : Integer;
  CPRColors : TN_BytesPtr;
begin
  with ColorScheme do begin
    CPCount := ALength;
    UniformPathPointWeight := (K_csbfUniformPathPointWeight in BuildFlags) or
                              (((RCount - 1) mod (CPCount - 1)) = 0);
    PCSColors := P();
    if (K_csbfUsePathPoints in BuildFlags) then begin
    // Fill Result Colors by Colors Path Control Points
      FullPathLeng := RCount * SizeOf(Integer);
      PathLeng := CPCount * SizeOf(Integer);
      CPRColors := TN_BytesPtr(PRColors);
      repeat
        CurPathLeng := PathLeng;
        if FullPathLeng < CurPathLeng then
          CurPathLeng := FullPathLeng;
        Move( PCSColors^, CPRColors^, CurPathLeng );
        Dec( FullPathLeng, CurPathLeng );
        Inc( CPRColors, CurPathLeng );
      until FullPathLeng <= 0;
    end else
      K_BuildColorsByColorPath( PCSColors, CPCount, PRColors, RCount, UniformPathPointWeight );
    if K_csbfReverseResultOrder in BuildFlags then
      K_DataReverse( PRColors^, SizeOf(Integer), RCount );
  end;
end; // end_of procedure K_BuildColorsByColorScheme


//***************************************** K_RebuildVectorMinMax
// Rebuil MVVector MinMax and "real" values vector
//
function K_RebuildVectorMinMax( var VMin, VMax : Double; RecalcMinMax : Boolean;
                    PData : PDouble; DStep : Integer; DCount : Integer;
                    PIndex : PInteger = nil; ICount : Integer = 0;
                    IDColCount : Integer = 0 ) : TN_DArray;
var
  DLength, i, Ind, SColStep : Integer;
begin

//  if (UDSVAttrs = nil) then UDSVAttrs := K_CurArchSpecVals;
  if PIndex = nil then ICount := DCount;
  if IDColCount = 0 then IDColCount := 1;
  DLength := IDColCount * ICount;
  SetLength( Result, DLength );
  if ICount > 0 then begin
    if PIndex = nil then
      K_MoveVector( Result[0], SizeOf(Double),
                               PData^, DStep, SizeOf(Double), DLength )
    else
    begin
      Ind := 0;
      SColStep := DStep * DCount;
      for i := 0 to IDColCount - 1 do
      begin
        K_MoveVectorBySIndex( Result[Ind], SizeOf(Double),
                              PData^, DStep, SizeOf(Double),
                              ICount, PIndex );
        Inc( Ind, ICount );
        Inc( TN_BytesPtr(PData), SColStep );
      end;
    end;
    Result := K_GetDVectorNotSpecValuesArray( @Result[0], Length(Result),
                                              PIndex );

//    Result := K_GetMVVectorNotSpecValues( @Result[0], Length(Result),
//                                          TK_UDRarray(UDSVAttrs).R, PIndex  );
    if RecalcMinMax or (VMin = K_MVMinVal) then VMin := MinValue( Result );
    if RecalcMinMax or (VMax = K_MVMinVal) then VMax := MaxValue( Result );
  end;
end; // end_of function K_RebuildVectorMinMax

//***************************************** K_BuildAxisTicksAttrs
// Buil Axis Ticks Visual Attributes
//
procedure K_BuildAxisTicksAttrs( out AAxisTickStep : Double;
                                var AAxisCharLength : Integer;
                                APAxisTickFormat, APAxisMarkText : PString;
                                AVMin, AVMax : Double; AAxisTickUnits : string = '' );
var
  FDAxisVal, FAxisStepCharsP, FAxisStepCharsN, FMinSrcStep,
  FSSLog, FMaxSSLog, FMaxRLog, DblResStepVal, ResStepVal : double;
  ResStepExp : Integer;
  AxisIncUnitsToTick, AxisIncUnitsToTickN, AxisIncUnitsToTickP : Boolean;


  function SelectAxisTextVal( AMin, AMax : Double ) : Double;
  var
    FVal, FV1, FV2 : double;
    GetV2 : Boolean;
  begin
    FV1 := Abs(AMin);
    FV2 := Abs(AMax);
    GetV2 := FV1 < FV2;
    FVal := FV1;
    Result := AMin;
    if GetV2 then begin
      FVal := FV2;
      Result := AMax;
    end;
    if (FVal < 1) and
       ( (    GetV2 and (FV1 > 0)) or
         (not GetV2 and (FV2 > 0)) ) then begin
       if GetV2 then
         Result := AMin
       else
         Result := AMax;
    end;
  end;

  function CalcAxisValStep( ) : Double;
  begin
//    with MVAttribs do begin
      FMinSrcStep := FDAxisVal * FAxisStepCharsP / AAxisCharLength; // Min Step
      FSSLog := Log10( FMinSrcStep );

      ResStepExp := Round( Floor( FSSLog ) );
      DblResStepVal := Power( 10, FSSLog - ResStepExp ); // in (1..10) range

       if DblResStepVal > 5 then begin
         ResStepVal := 1;
         Inc(ResStepExp);
       end else if DblResStepVal > 2 then ResStepVal := 5
       else if DblResStepVal > 1.05 then ResStepVal := 2
       else ResStepVal := 1;

      Result := ResStepVal * Power( 10, ResStepExp );
//    end;
  end;

  function CalcAxisStepChars( Val : Double; UseStep : Boolean ) : Double;
  begin
    FMaxSSLog := Log10( Abs(Val) );
    FMaxRLog := Round( Floor( FMaxSSLog ) );
    if FMaxRLog >= 0 then
      Result := FMaxRLog + 1
    else
      Result := - FMaxRLog + 1.5; // 1.5 -> place for '0.'
    if Val < 0 then
      Result := Result + 1; // add place for '-'


    if UseStep then begin
      if FMaxRLog >= 0 then begin
      // Positive Boudary Exp Value
        if ResStepExp < 0 then
          Result := Result + ResStepExp + 0.5 // 0.5 for decimal point
        else if FMaxRLog < ResStepExp then
          Result := Result + ResStepExp - FMaxRLog;
      end else begin
      // Negative Boudary Exp Value
        if FMaxRLog > ResStepExp  then
          Result := Result + FMaxRLog - ResStepExp;
      end;
    end;

    AxisIncUnitsToTick := (Length(AAxisTickUnits) = 1) and (Result < 4);
    if AxisIncUnitsToTick then // place single char units to Axis Tick Marks
      Result := Result + 1;

    Result := Result + 1; // add Marks gap in chars
  end;

begin

// Calculate Axis Attributes
  // Calculate approximate  Tick Step in chars
  FAxisStepCharsP := CalcAxisStepChars( SelectAxisTextVal( AVMin, AVMax ), false );
  AxisIncUnitsToTickP := AxisIncUnitsToTick;

  // Calculate Tick Step in Value Units
  FDAxisVal := AVMax - AVMin;
  if AAxisCharLength = 0 then AAxisCharLength := 40;
  AAxisTickStep := CalcAxisValStep( );

  // Calculate final Tick Step in chars taking into account Tick Step
  FAxisStepCharsN := CalcAxisStepChars( SelectAxisTextVal(
               AAxisTickStep * Ceil(AVMin / AAxisTickStep),
               AAxisTickStep * FLoor(AVMax / AAxisTickStep) ), true );
  AxisIncUnitsToTickN := AxisIncUnitsToTick;

  if FAxisStepCharsN > FAxisStepCharsP then begin
  // Recalculate Tick Step in Value Units
    FAxisStepCharsP := FAxisStepCharsN;
    AxisIncUnitsToTickP := AxisIncUnitsToTickN;
    AAxisTickStep := CalcAxisValStep( );
  end;


  // Prep Axis Marks Format and Axis Mark Text
  if ResStepExp < 0 then
    ResStepExp := - ResStepExp
  else
    ResStepExp := 0;
  APAxisTickFormat^ := '%.'+IntToStr(ResStepExp)+'f';
  if AxisIncUnitsToTickP then begin
    APAxisTickFormat^ := APAxisTickFormat^ + AAxisTickUnits;
    if AAxisTickUnits = '%' then
      APAxisTickFormat^ := APAxisTickFormat^ + '%';
    if APAxisMarkText <> nil then APAxisMarkText^ := '';
  end else begin
    if APAxisMarkText <> nil then APAxisMarkText^ := AAxisTickUnits;
  end;

end; // end_of function K_BuildAxisTicksAttrs

//***************************************** K_RebuildMVAttribs
// Rebuil MVVector Visual Attributes
//
//    Parameters
// MVAttribs      - Visual Attributes structure
// APMVVEctor     - pointer to TK_MVVector structure
// ColorSchemeInd - Color Scheme index in given RArray of Color Schemes AColorSchemes or
//                  in global context Color Schemes, if =-1 then Color Schemes are not used
// AColorSchemes  - given RArray of Color Schemes, if =nil then global context Color Schemes will be used
//
procedure K_RebuildMVAttribs( var MVAttribs : TK_MVVAttrs; APMVVEctor : TK_PMVVector;
              ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil );
var
  AutoRangeIndexes : TN_IArray;
  PIndex : PInteger;
  ICount : Integer;
begin
  with APMVVEctor^, D, MVAttribs do
  begin
    AutoRangeIndexes := nil; // warning precaution
    PIndex := nil;
    ICount := 0;
    if (AutoRangeCSS <> nil) then
    begin // Add Indexes Recalculation by AutoRangeCSS
      // AutoRangeIndexes
      ICount := TK_UDDCSSpace(AutoRangeCSS).PDRA.ALength;
      SetLength( AutoRangeIndexes, ICount );
      if K_BuildDataProjectionByCSProj( TK_UDDCSSpace(CSS),
                                        TK_UDDCSSpace(AutoRangeCSS),
                                        @AutoRangeIndexes[0], nil ) then
        PIndex := @AutoRangeIndexes[0];
    end;

    K_RebuildMVAttribs( MVAttribs, P, ElemSize, ALength,
                        ColorSchemeInd, AColorSchemes, PIndex, ICount );
  end;
end; // end_of procedure K_RebuildMVAttribs

//***************************************** K_RebuildMVAttribs
// Rebuil MVVector Visual Attributes
//
//    Parameters
// MVAttribs      - Visual Attributes structure
// VV             - Data RArray
// ColorSchemeInd - Color Scheme index in given RArray of Color Schemes AColorSchemes or
//                  in global context Color Schemes, if =-1 then Color Schemes are not used
// AColorSchemes  - given RArray of Color Schemes, if =nil then global context Color Schemes will be used
// PIndex         - pointer to 1-st element in array of index of data elements
//                  to use for Visual Attributes rebuild, if =nil then Indexes are not used
// ICount         - indexes counter for data elements
//
procedure K_RebuildMVAttribs( var MVAttribs : TK_MVVAttrs; VV : TK_RArray;
              ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil;
              PIndex : PInteger = nil; ICount : Integer = 0 );
begin
  with VV do
    K_RebuildMVAttribs( MVAttribs, P, ElemSize, ALength,
                        ColorSchemeInd, AColorSchemes, PIndex, ICount );
end; // end_of procedure K_RebuildMVAttribs

//***************************************** K_GetMVStandardValToTextPattern
// Get Standard Value To Text Macro Pattern
//
//    Parameters
// APat - Resulting Macro Pattern
// APatType - standard patterns enumeration
//
procedure K_GetMVStandardValToTextPattern( var APat : string; APatType : TK_MVValToTextPatType0 );
begin
  case APatType of
    K_vttNameValue : APat := '(#Name#) - (#Value#)(#Units#)';
    K_vttNameRange : APat := '(#Name#) - (#Range#)';
    K_vttName      : APat := '(#Name#)';
    K_vttRange     : APat := '(#Range#)';
    K_vttValue     : APat := '(#Value#)';
    K_vttUValue    : APat := '(#Value#)(#Units#)';
  end;
end; // procedure K_GetMVStandardValToTextPattern

//***************************************** K_RebuildMVAttribs
// Rebuil MVVector Visual Attributes
//
//    Parameters
// MVAttribs      - Visual Attributes structure
// PData          - pointer to data (Double) for Visual Attributes rebuild
// DStep          - data element step in bytes
// DCount         - data elements count, if PIndex = nil, then all data elements count,
//                  if PIndex <> nil, then Indexed Coloumn data elements count
// ColorSchemeInd - Color Scheme index in given RArray of Color Schemes AColorSchemes or
//                  in global context Color Schemes, if =-1 then Color Schemes are not used
// AColorSchemes  - given RArray of Color Schemes, if =nil then global context Color Schemes will be used
// PIndex         - pointer to 1-st element in array of index of data elements column
//                  to use for Visual Attributes rebuild, if =nil then Indexes are not used
// ICount         - indexes counter for data elements column
// IDColCount     - data elements columns counter
//
procedure K_RebuildMVAttribs( var MVAttribs : TK_MVVAttrs;
                    PData : PDouble; DStep : Integer; DCount : Integer;
                    ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil;
                    PIndex : PInteger = nil; ICount : Integer = 0;
                    IDColCount : Integer = 0 );
var
  InitMode : Boolean;
  PureValues : TN_DArray;
  PureWeights : TN_DArray;
  WInds : TN_IArray;
  WRanges : TN_DArray;
  WCapts : TN_SArray;
  NumRanges, i, j : Integer;
  SL : THashedStringList;
  ValPatType : TK_MVValToTextPatType;
  PRange : PDouble;
  MacroFormatStrInd : Integer;
  WStr : string;
  WFormat : string;
  WRDPPos : Integer;
  AutoWAverageFlag : Boolean;


  procedure CopyRangeValues;
  begin
    NumRanges := Length(WRanges);
    MVAttribs.RangeValues.ASetLength(NumRanges);
    if NumRanges > 0 then
      MVAttribs.RangeValues.SetElems(WRanges[0], false );
  end;

  procedure BuildColors( CCount : Integer );
  var
    PRAColorsSet : TK_PRArray;
    BuildFlags : TK_ColorSchemeBuildFlags;
  begin
    with MVAttribs do begin
      RangeColors.ASetLength( CCount );
      if ColorSchemes <> nil then AColorSchemes := ColorSchemes;
      if (ColorsSet <> nil) and ((ColorSchemeInd = -1) or (AColorSchemes.ALength <= 0)) then
        PRAColorsSet := K_GetPVRArray(ColorsSet)
      else
        PRAColorsSet := K_GetPRAColorScheme( AColorSchemes, ColorSchemeInd );
      if PRAColorsSet = nil then Exit;
      BuildFlags := [];
      if (ColorsSetOrder.T = K_cotIndirect) then BuildFlags := [K_csbfReverseResultOrder];
      if BuildColorsType.T = K_cctNoConvertion then
        BuildFlags := BuildFlags + [K_csbfUsePathPoints];
      K_BuildColorsByColorScheme( PInteger(RangeColors.P), CCount,
                                   PRAColorsSet^, BuildFlags );
    end;
  end;
begin

  WRanges := nil;
  with MVAttribs do begin
    InitMode := (UDSVAttrs = nil);
    if InitMode then begin
// init
      if (RangeCount = 0) and (ValueType.T = K_vdtContinuous) then RangeCount := 3;
      K_SetUDRefField( UDSVAttrs, K_CurArchSpecVals );
      RangeValues := K_RCreateByTypeCode( Ord(nptDouble) );
      RangeCaptions := K_RCreateByTypeCode( Ord(nptString) );
      RangeColors := K_RCreateByTypeCode( Ord(nptColor) );
    end;
    if InitMode or (RangeValues = nil) then begin
      InitMode := true;
      RangeValues.ARelease;
      RangeValues := K_RCreateByTypeCode( Ord(nptDouble) );
      RangeCaptions.ARelease;
      RangeCaptions := K_RCreateByTypeCode( Ord(nptString) );
    end;

    if ColorsSet = nil then
//      K_SetUDRefField( ColorsSet, K_CurArchDefColorsSet );
      K_SetVArrayField( ColorsSet, K_CurArchDefColorsSet );
    //*** Rebuild Min/Max


    AutoWAverageFlag := (InitMode or
        (AutoRangeVals.T = K_aumAuto))  and
        (ValueType.T = K_vdtContinuous) and
        (AutoRangeType.T = K_artWAverage4);

    if PIndex = nil then
      ICount := DCount
    else
    begin
      // Copy Given Indexes to Wrk Array, because it maybe changed in K_RebuildVectorMinMax
      SetLength( WInds, ICount );
      Move( PIndex^, WInds[0], SizeOf(Integer) * ICount );
    end;

    if AutoWAverageFlag then
    begin
      IDColCount := 0; // This Type of Range Calculation Should be used only for 1-st data column
      if PIndex = nil then
      begin
        // Create Indexes to Wrk Array for future Weights Array Build
        SetLength( WInds, ICount );
        K_FillIntArrayByCounter( @WInds[0], ICount );
      end;
    end;

    //*** Rebuild Ranges
    PureValues := K_RebuildVectorMinMax( VMin, VMax,
                    (AutoMinMax.T = K_aumAuto) or (VMin = VMax),
                    PData, DStep, DCount,
                    PIndex, ICount, IDColCount );
    if ICount > 0 then
    begin
      if (VBase < VMin) or (VBase > VMax) then VBase := VMin;
    end;

    ICount := Length(PureValues); // Data Counter may be changed after K_RebuildVectorMinMax
    PureWeights := nil;
    if AutoWAverageFlag and (AutoRangeWData <> nil) then
    begin
    // Build Weights Array
      SetLength( PureWeights, ICount );
      with TK_UDVector(AutoRangeWData) do
        K_MoveVectorBySIndex( PureWeights[0], SizeOf(Double),
                              PDE(0)^, SizeOf(Double), SizeOf(Double),
                              ICount, @WInds[0] );
    end;

    // Calculate Axis Attributes
    if ((AutoAxisTicks.T = K_aumAuto) or (AxisTickStep = 0)) and
       (VMin <> VMax) then begin
      K_BuildAxisTicksAttrs( AxisTickStep, AxisCharLength,
                            @AxisTickFormat, @AxisMarkText, VMin, VMax,
                            AxisTickUnits );
    end;

    ValPatType := PureValPatType;
    if PureValPatType.T = K_vttAuto then ValPatType.T := K_vttValue;
    K_GetMVStandardValToTextPattern( PureValToTextPat, ValPatType.T );
    ValPatType := NamedValPatType;
    if NamedValPatType.T = K_vttAuto then ValPatType.T := K_vttNameValue;
    K_GetMVStandardValToTextPattern( NamedValToTextPat, ValPatType.T );
//*** Build Range Values
    NumRanges := RangeValues.ALength;
    if InitMode or
       (AutoRangeVals.T = K_aumAuto) then
    begin
    //*** Rebuild Ranges
      if ValueType.T = K_vdtContinuous then
      begin
      //*** Continuous Values Set
        case AutoRangeType.T of
//          K_artEqualSize   : WRanges := K_BuildEqualWidthRanges( PureValues, RangeCount, RDPPos );
          K_artEqualStep   : WRanges := K_BuildEquidistantRanges( VMin, VMax, RangeCount, RDPPos );
          K_artOptimal     : WRanges := K_BuildOptimalRanges3( PureValues, RangeCount, 100 );
//          K_artOptimal     : WRanges := K_BuildOptimalRanges3( PureValues, RangeCount, RDPPos );
//          K_artOptimal     : WRanges := K_BuildOptimalRanges2( PureValues, RangeCount, RDPPos );
//          K_artOptimal     : WRanges := K_BuildOptimalRanges1( PureValues, RangeCount, RDPPos );
          K_artEqualNElems : WRanges := K_BuildEqualNElemsRanges( PureValues, RangeCount, 100 );
//          K_artEqualNElems : WRanges := K_BuildEqualNElemsRanges( PureValues, RangeCount, RDPPos );
          K_artWAverage4   : WRanges := K_BuildWeightedAverageRanges( PureValues, PureWeights, 2, RDPPos );
          K_artBestWorst10 : WRanges := K_BuildBestWorstRanges( PureValues, 10, RDPPos );
          K_artStdDev123   : begin
            WRDPPos := RDPPos;
            WRanges := K_BuildStandardDeviationRanges( @PureValues[0], ICount, WRDPPos, 0 );
          end;

        end;
        CopyRangeValues();
        BuildColors( NumRanges + 1 );
      end
      else
      begin
      //*** Discrete Values Set
        WRanges := K_BuildDiscreteRanges( PureValues, K_MVMinVal, K_MVMaxVal );
        NumRanges := Length(WRanges);
        SetLength( WCapts, NumRanges );
        for i := 0 to NumRanges - 1 do
        begin
          j := K_IndexOfDoubleInScale( PDouble(RangeValues.P), RangeValues.AHigh,
            SizeOf(Double), WRanges[i] ) - 1;
          if (j >= 0) and
             (PDouble(RangeValues.P(j))^ = WRanges[i]) then
            WCapts[i] := PString(RangeCaptions.P(j))^
          else
            WCapts[i] := FloatToStr( WRanges[i] );
        end;
        RangeCaptions.ASetLength(NumRanges);
        RangeCaptions.SetElems(WCapts[0], false );
        CopyRangeValues();
        BuildColors( NumRanges );
      end;
    end;

//*** Build Range Captions for Continuous Values
    if ValueType.T = K_vdtContinuous then
    begin
      RangeCaptions.ASetLength( NumRanges + 1 );
      if InitMode or
       (AutoRangeCapts.T = K_aumAuto) then
      begin
        if AutoCaptsFormat = nil then
        begin
        //*** Build Auto Captions format
          AutoCaptsFormat := K_RCreateByTypeCode( Ord(nptString), 3 );
          PString(AutoCaptsFormat.P)^    := '< (#CLimit#)';
          PString(AutoCaptsFormat.P(1))^ := '(#PLimit#) - (#CLimit#)';
          PString(AutoCaptsFormat.P(2))^ := '> (#PLimit#)';
        end;
        if NumRanges >= 0 then
        begin
          PRange := PDouble(RangeValues.P);
          if RFormat <> '' then
            WFormat := RFormat
          else
          begin
            WRDPPos := Max(RDPPos, 0);
            WFormat := '%.'+IntToStr(WRDPPos)+'f';
          end;

          SL := THashedStringList.Create;
          for i := 0 to 3 do SL.Add('');

          WStr := format( WFormat, [VMin]);
          SL[1] := 'PLimit='+WStr;
          SL[3] := 'RangeP='+WStr;
          PString(RangeCaptions.P)^ := K_StringMListReplace(
              PString(AutoCaptsFormat.P)^, SL, K_ummRemoveMacro );
          MacroFormatStrInd := 0;
          for i := 0 to NumRanges - 1 do
          begin
            WStr := format( WFormat, [PRange^]);
            SL[0] := 'CLimit='+WStr;
            SL[2] := 'Range='+WStr;
            PString(RangeCaptions.P(i))^ := K_StringMListReplace(
              PString(AutoCaptsFormat.P(MacroFormatStrInd))^, SL, K_ummRemoveMacro );
            SL[1] := 'PLimit='+WStr;
            SL[3] := 'RangeP='+WStr;
            if MacroFormatStrInd = 0 then MacroFormatStrInd := 1;
            Inc(PRange);
          end;
          SL[0] := 'CLimit='+format( WFormat, [VMax]);
          PString(RangeCaptions.P(NumRanges))^ := K_StringMListReplace(
              PString(AutoCaptsFormat.P(2))^, SL, K_ummRemoveMacro );
        end
        else
          PString(RangeCaptions.P)^ := '*';
       end;
      BuildColors( NumRanges + 1 );
    end;
  end;

end; // end_of function K_RebuildMVAttribs

//***************************************** K_CopyMVAttribs
// Copy Data Based MVAttribs Fields
//
procedure K_CopyMVAttribs( var DestMVAttribs : TK_MVVAttrs;
                           const SrcMVAttribs : TK_MVVAttrs );
begin
  with DestMVAttribs do begin
    RangeValues.ASetLength( SrcMVAttribs.RangeValues.ALength );
    RangeValues.SetElems( SrcMVAttribs.RangeValues.P^, false );
    RangeCaptions.ASetLength( SrcMVAttribs.RangeCaptions.ALength );
    RangeCaptions.SetElems( SrcMVAttribs.RangeCaptions.P^, false );
    RangeColors.ASetLength( SrcMVAttribs.RangeColors.ALength );
    RangeColors.SetElems( SrcMVAttribs.RangeColors.P^, false );

    AutoRangeVals.R := SrcMVAttribs.AutoRangeVals.R;
    RangeCount := SrcMVAttribs.RangeCount;
    AutoRangeType := SrcMVAttribs.AutoRangeType;
    RDPPos := SrcMVAttribs.RDPPos;

    AutoRangeCapts.R := SrcMVAttribs.AutoRangeCapts.R;
    PString(AutoCaptsFormat.P(0))^ := PString(SrcMVAttribs.AutoCaptsFormat.P(0))^;
    PString(AutoCaptsFormat.P(1))^ := PString(SrcMVAttribs.AutoCaptsFormat.P(1))^;
    PString(AutoCaptsFormat.P(2))^ := PString(SrcMVAttribs.AutoCaptsFormat.P(2))^;

    VDPPos := SrcMVAttribs.VDPPos;

    AutoMinMax.R := SrcMVAttribs.AutoMinMax.R;     // Manual Mode
    VMin := SrcMVAttribs.VMin;
    VMax := SrcMVAttribs.VMax;
  end;

end; // end_of function K_CopyMVAttribs

//********************************************** K_CanAddToMVWFolder
//
function K_CanAddToMVWFolder( AddPar : Integer): Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdWebCartGroupWins,
    K_msdWebCartWins,
    K_msdWebVHTMWins,
    K_msdWebVHTMRefWins,
    K_msdWebVTreeWins,
    K_msdWebTableWins,
    K_msdWebLDiagramWins,
    K_msdWebWinGroups,
    K_msdWebHTMWins,
    K_msdWebHTMRefWins,
    K_msdWebFolder : Result := true;
  else
    Result := false;
  end;
end;

//********************************************** K_AddMVChildToSubTree
//
procedure K_SetChildUniqNames( Parent, Child : TN_UDBase; ObjSysType : TK_MVDARSysType );
begin
  if Parent = Child.Owner then
    with Parent do begin
      Child.ObjName := K_MVDARSysObjNames[Ord(ObjSysType)]+IntToStr(Integer(Child));
      BuildUniqChildName( '', Child );
      if Child.ObjAliase <> '' then
        BuildUniqChildName( '', Child, K_ontObjAliase );
    end;
end;

//********************************************** K_AddMVChildToSubTree
//
function K_AddMVChildToSubTree( AParent : TN_UDBase; PDE : TK_PDirEntryPar;
       CopyPar : TK_CopySubTreeFlags; FolderObjSysType : TK_MVDARSysType = K_msdUndef ) : Boolean;
var
  ObjSysType : TK_MVDARSysType;
begin
  Result := false;
  if PDE <> nil then
    with AParent, PDE^ do begin
      ObjSysType := K_MVDarGetUserNodeType( Child );
      if not CanAddChildByPar( Ord(ObjSysType) ) then Exit;
      if not (K_mvcCopySelf in CopyPar) and
         ( (K_mvcCopyChildRefs in CopyPar) or
           ( (FolderObjSysType = K_msdUndef) and
             (K_mvcCopyFolders in CopyPar) ) or
           ( (K_mvcCopyOwnedChilds in CopyPar) and
             (Parent <> Child.Owner) ) ) then
        CopyPar := []; // Skip Subtree Copy
      if (FolderObjSysType <> K_msdUndef) and
         (CopyPar <> []) and
         (K_mvcCopyFolders in CopyPar) and
         (ObjSysType <> FolderObjSysType) then Exit;
      Child := Child.SelfCopy( CopyPar );
      AddOneChildV( Child );
      K_SetChildUniqNames( AParent, Child, ObjSysType );
    end;
  Result := true;
end;

//********************************************** K_BuildMVDoublesRepresentations
//  Build Colors, Texts, or NamedTexts from Doubles using MVAttribs
//
procedure K_BuildMVVElemsVAttribs( PData : PDouble; DCount : Integer;
                  PMVVAttrs : TK_PMVVAttrs;
                  PCSSInds : PInteger = nil;
                  PTextValues : PString = nil;
                  PNamedTextValues : PString = nil;
                  PColors : PInteger = nil;
                  PSWInds : Pointer = nil; PSVA : TK_PSpecValsAssistant = nil;
                  Units : string = '' );
var
  PWData : PDouble;
  PScale : PDouble;
  ScaleHigh : Integer;
  SWInds : TN_IArray;
  WInds : TN_IArray;
  i, n : Integer;
  SVA : TK_SpecValsAssistant;
  RangeText : string;
  WList : TStringList;
  AddNameFlag : Boolean;
  SValNamedPat, SValPat, CurPat : string;

begin
  with PMVVAttrs^ do begin
    K_GetMVStandardValToTextPattern( SValPat, K_vttRange );
    K_GetMVStandardValToTextPattern( SValNamedPat, K_vttNameRange );
    SetLength( WInds, DCount );
    PScale := PDouble(RangeValues.P);
    ScaleHigh := RangeValues.AHigh;
    PWData := PData;
    if PSVA <> nil then
      SVA := PSVA^
    else
      SVA := nil;
    SWInds := nil;
  //*** Build Scale Indexes Vector:
  //  n < 0  - SpecialValues Index - 1
  //  n >= 0 - RangeColors Index
    for i := 0 to DCount - 1 do begin
      if ( K_MVMinVal > PWData^ ) or
         ( K_MVMaxVal < PWData^ ) then begin
        if SVA = nil then begin
          SVA := TK_SpecValsAssistant.Create( TK_UDRArray(UDSVAttrs).R );
          SetLength( SWInds, SVA.ScaleHigh + 1 );
        end;
        n := SVA.IndexOfSpecVal( PWData^ );
        if n < 0 then n := 0;
        WInds[i] := -n - 1;
        SWInds[n] := 1;  // Used Special Value Flag
      end else begin
  //*** Not Spec Value
        n := K_IndexOfDoubleInScale( PScale, ScaleHigh, sizeof(Double), PWData^ );
        if (n > 0) and (ValueType.T = K_vdtDiscrete) then Dec(n);
        WInds[i] := n;
      end;
      Inc(PWData);
    end;

  //*** Build Colors Vector:
    if PColors <> nil then
      for i := 0 to DCount - 1 do begin
        n := WInds[i];
        if n < 0 then // Spec Value
          PColors^ := SVA.GetSpecValAttrs( -n - 1 ).Color
        else          // Ordinary Value
          PColors^ := PInteger( RangeColors.P(n) )^;
        Inc(PColors);
      end;


    if (PTextValues <> nil) or (PNamedTextValues <> nil) then begin
      WList := TStringList.Create;
      WList.Add('Range=');
      WList.Add('Value=');
      AddNameFlag := (ElemCapts <> nil) and (PCSSInds <> nil);
      if AddNameFlag then
        WList.Add('Name=');
      if Units <> '' then
        WList.Add('Units='+Units);
      PWData := PData;
      for i := 0 to DCount - 1 do begin
        if AddNameFlag then begin
          WList[2] := 'Name='+PString(TK_UDVector(ElemCapts).DP(PCSSInds^))^;
          Inc(PCSSInds);
        end;
        n := WInds[i];
        if n < 0 then // Spec Value
          RangeText := SVA.GetSpecValAttrs( -n + 1 ).Caption
        else     // Ordinary Value
          RangeText := PString(RangeCaptions.P(n))^;
        WList[0] := 'Range='+RangeText;
        if n >= 0 then begin // Ordinary  Value
          if VFormat <> '' then
            RangeText := format( VFormat, [PWData^])
          else
            RangeText := format('%.*f', [VDPPos, PWData^]);
        end;
        WList[1] := 'Value='+RangeText;
        if PTextValues <> nil then
        begin
          CurPat := PureValToTextPat;
          if n < 0 then
            CurPat := SValPat;
          PTextValues^ := K_StringMListReplace(
            CurPat, WList, K_ummRemoveMacro );
          Inc(PTextValues);
        end;
        if PNamedTextValues <> nil then
        begin
          CurPat := NamedValToTextPat;
          if n < 0 then
            CurPat := SValNamedPat;
          PNamedTextValues^ := K_StringMListReplace(
            CurPat, WList, K_ummRemoveMacro );
          Inc(PNamedTextValues);
        end;
        Inc(PWData);
      end;
      WList.Free;
    end;

  end;
  if PSWInds <> nil then
    TN_PIArray(PSWInds)^ := SWInds;
  if PSVA = nil then
    SVA.Free
  else
    PSVA^ := SVA;
end; // end_of K_BuildMVVElemsVAttribs

//********************************************** K_IfShowCorPictPlane
//  Check if Correlation Picture Plane must be shown
//
function K_IfShowCorPictPlane( PMVCorPictPlane : TK_PMVCorPictPlane;
                           ProcessInvisiblePlane : Boolean = false ) : Boolean;
begin
  with PMVCorPictPlane^ do
    Result := (ProcessInvisiblePlane or (K_drpVisible in DRPFlags)) and
              (DRPVX.UDVA <> nil)        and
              (DRPVY.UDVA <> nil);
end; // end_of K_IfShowCorPictPlane

{*** TK_UDMVFolder ***}

//********************************************** TK_UDMVFolder.Create
//
constructor TK_UDMVFolder.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVFolderCI;
  ImgInd := 30;
end;

//************************************** TK_UDMVFolder.CanMoveChilds
//  returns True if Node Cane Move Childs
//
function TK_UDMVFolder.CanMoveChilds( ): Boolean;
begin
  Result := true;
end; // end_of function TK_UDMVFolder.CanMoveChilds

//************************************** TK_UDMVFolder.CanMoveDE
//  returns True if Node Cane Move Childs
//
function TK_UDMVFolder.CanMoveDE( const DE : TN_DirEntryPar ): Boolean;
begin
  Result := true;
end; // end_of function TK_UDMVFolder.CanMoveDE

//************************************** TK_UDMVFolder.CanAddChildByPar
//  returns True if Child specified by AddPar can be added to this Node
//
function TK_UDMVFolder.CanAddChild( Child : TN_UDBase ): Boolean;
begin
  Result := CanAddChildByPar( Ord( K_MVDarGetUserNodeType(Child) ) );
end;

//********************************************** TK_UDMVFolder.CanAddChildByPar
//  returns True if Child specified by AddPar can be added to this Node
//
function TK_UDMVFolder.CanAddChildByPar( AddPar : Integer ) : Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdUndef, K_msdMVVectors, K_msdMVVAtribs : Result := false;
  else
    Result := true;
  end;
end;

//********************************************** TK_UDMVFolder.AddChildToSubTree
//
function TK_UDMVFolder.AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean;
begin
  Result := K_AddMVChildToSubTree( Self, PDE, CopyPar, K_msdFolder );

end;

//********************************************** TK_UDMVFolder.RemoveSelfFromSubTree
//
function TK_UDMVFolder.RemoveSelfFromSubTree(PDE: TK_PDirEntryPar): Boolean;
begin
  if PDE = nil then
    Result := true
  else
    with PDE^ do
      Result := K_RemoveMVDarFolderElement( Parent, DirIndex );
end;

//********************************************** TK_UDMVFolder.DeleteSubTreeChild
//
function TK_UDMVFolder.DeleteSubTreeChild(Index: Integer): Boolean;
begin
  if Index = -1 then Result := true
  else
    Result := (DeleteDirEntry(Index) <= K_DRisOK);
end;

{*** end of TK_UDMVFolder ***}

{*** TK_UDMVLayout ***}

//********************************************** TK_UDMVVWLayout.Create
//
constructor TK_UDMVVWLayout.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVVWLayoutCI;
  ImgInd := 70;
end;

//********************************************** TK_UDMVVWLayout.CanAddChildByPar
//
function TK_UDMVVWLayout.CanAddChildByPar( AddPar : Integer): Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdVWindows : Result := true;
  else
    Result := false;
  end;
end;

//********************************************** TK_UDMVVWLayout.AddChildToSubTree
//
function TK_UDMVVWLayout.AddChildToSubTree( PDE : TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ) : Boolean;
begin
  Result := K_AddMVChildToSubTree( Self, PDE, CopyPar );
end;

//********************************************** TK_UDMVVWLayout.GetMVVWindowList
//
procedure TK_UDMVVWLayout.GetMVVWindowList( VWList : TStrings; SaveFrameSets : Boolean );
var
  i,h : Integer;
  UDChild : TN_UDBase;
begin
  h := DirHigh;
  for i := 0 to h do begin
    UDChild := DirChild(i);
    if UDChild is TK_UDMVVWindow then
      TK_UDMVVWindow(UDChild).GetMVVWindows( VWList, SaveFrameSets );
  end;
end;

{*** end of TK_UDMVVWLayout ***}

{*** TK_UDMVVector ***}

//********************************************** TK_UDMVVector.Create
//
constructor TK_UDMVVector.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVVectorCI;
end;

//********************************************** TK_UDMVVector.RemoveSelfFromSubTree
//
function TK_UDMVVector.RemoveSelfFromSubTree( PDE: TK_PDirEntryPar ): Boolean;
var
  AttrsUDParent : TN_UDBase;
begin
  if PDE = nil then
    Result := true
  else
    with PDE^ do begin
      Result := false;
      if (PDE^.Parent = Self.Owner) and (Self.RefCounter > 2) then Exit; //*** Vector is Used ->> Deletion is disabled
      AttrsUDParent := Parent.Owner.DirChild(1);
      with AttrsUDParent do
        if (AttrsUDParent = DirChild(DirIndex).Owner) and
           (RefCounter > 1) then Exit; //*** Vector Attrs Object is Used ->> Deletion is disabled
      Result := Parent.Owner.DeleteSubTreeChild(DirIndex);
//      Result := K_RemoveMVDarFolderElement( Parent.Owner, PIndex );
    end;
end;

//************************************** TN_UDBase.GetSubTreeParent
//  returns Application SubTree Parent Node
//
function TK_UDMVVector.GetSubTreeParent( const DE : TN_DirEntryPar ): TN_UDBase;
begin
  Result := DE.Parent.Owner;
end; // end_of function TK_UDMVVector.GetSubTreeParent

{*** end of TK_UDMVVector ***}

{*** TK_UDMVTable ***}

//********************************************** TK_UDMVTable.Create
//
constructor TK_UDMVTable.Create;
begin
  inherited Create;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVTableCI;
  ImgInd := 38;
end; // end_of constructor TK_UDMVTable.Create

//********************************************** TK_UDMVTable.Init
//
procedure TK_UDMVTable.Init( UDCSSpace : TN_UDBase );
var
  UDB : TN_UDBase;
begin
  if DirChild(0) <> nil then Exit;
  UDB := AddOneChild( TK_UDDCSSpace(UDCSSpace).CreateDTable( 'Vectors', Ord(nptDouble) ) );
  UDB.ObjAliase := 'Вектора';
  AddChildVnodes(0);
  UDB := AddOneChild( TN_UDBase.Create );
  UDB.ObjName := 'Attribs';
  UDB.ObjAliase := 'Атрибуты';
  AddChildVnodes(1);
end;

//********************************************** TK_UDMVTable.CreateMVAttribs
//
function TK_UDMVTable.CreateMVAttribs( Name : string; AttrsNum : Integer = 1 ) : TN_UDBase;
begin
  Result := K_CreateUDByRTypeName( 'TK_MVVAttrs', AttrsNum );
  Result.ObjName := Name;
end;

//********************************************** TK_UDMVTable.CreateMVVector
//
function TK_UDMVTable.CreateMVVector( Name : string ) : TN_UDBase;
begin
  Result := TK_UDSSTable( DirChild(0) ).CreateDVector( Name, Ord(nptDouble),
                        nil, K_GetTypeCodeSafe('TK_MVVector').All, K_UDMVVectorCI )
end;

//********************************************** TK_UDMVTable.AddColumn
//
function TK_UDMVTable.CreateColumn( Aliase : string = ''; Name : string = '';
                                  AttrsNum : Integer = 1 ) : Integer;
var
  UDB : TN_UDBase;
  WName, WAliase : string;
//  VV : TK_RArray;
  UDV : TN_UDBase;

  procedure SetNames( Ind : Integer );
  begin
    WName := Name;
    if WName = '' then WName := K_MVDARSysObjNames[Ind];
    WName := UDB.BuildUniqChildName( WName );
    WAliase := Aliase;
    if WAliase = '' then WAliase := K_MVDARSysObjAliases[Ind];
//    WAliase := UDB.BuildUniqChildName( WAliase, nil, K_ontObjAliase );
  end;

begin
//*** Add New Vector
  UDB := DirChild(0);
  SetNames( Ord(K_msdMVVectors) );
  Result := UDB.DirLength;
  UDB := UDB.AddOneChildV( CreateMVVector( WName ) );
  K_SetChangeSubTreeFlags( UDB );
  UDB.ObjAliase := WAliase;
//  VV := TK_PMVVector(TK_UDRArray(UDB).R.P).D;
  UDV := UDB;
  UDB := DirChild(1);
  SetNames( Ord(K_msdMVVAtribs) );
  UDB := UDB.AddOneChildV( CreateMVAttribs( WName, AttrsNum ) );
  K_SetChangeSubTreeFlags( UDB );
  UDB.ObjAliase := WAliase;
  K_RebuildMVAttribs( TK_PMVVAttrs(TK_UDRArray( UDB ).R.P)^, TK_PMVVector(TK_UDRArray(UDV).R.P) );
//  K_RebuildMVAttribs( TK_PMVVAttrs(TK_UDRArray( UDB ).R.P)^, VV );
end;

//********************************************** TK_UDMVTable.InitColAttribs
//
procedure TK_UDMVTable.InitColAttribs( Ind : Integer = -1;
             ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil );
var
  UDV : TN_UDBase;
  UDA : TN_UDBase;
  i, i1, i2 : Integer;

begin
  UDV := DirChild(0);
  UDA := DirChild(1);
  i1 := 0;
  i2 := UDV.DirHigh;
  if (Ind >= 0) and (Ind <= i2) then begin
    i1 := Ind;
    i2 := Ind;
  end;

  for i := i1 to i2 do begin
//    K_RebuildMVAttribs( TK_PMVVAttrs(TK_UDRArray( UDA.DirChild(i) ).R.P)^, TK_PMVVector(TK_UDRArray(UDV.DirChild(i)).R.P).D,
    K_RebuildMVAttribs( TK_PMVVAttrs(TK_UDRArray( UDA.DirChild(i) ).R.P)^, TK_PMVVector(TK_UDRArray(UDV.DirChild(i)).R.P),
                                         ColorSchemeInd, AColorSchemes );
  end;
end; // end of TK_UDMVTable.InitColAttribs

//************************************** TK_UDMVTable.CanMoveChilds
//  returns True if Node Cane Move Childs
//
function TK_UDMVTable.CanMoveChilds( ): Boolean;
begin
  Result := true;
end; // end_of function TK_UDMVTable.CanMoveChilds

//************************************** TK_UDMVTable.CanMoveDE
//  returns True if Node Cane Move Childs
//
function TK_UDMVTable.CanMoveDE( const DE : TN_DirEntryPar ): Boolean;
begin
  Result := (DE.Parent.Owner = Self);
end; // end_of function TK_UDMVTable.CanMoveDE

//********************************************** TK_UDMVTable.CanAddChildByPar
//
function TK_UDMVTable.CanAddChildByPar(AddPar : Integer): Boolean;
begin
  Result := (AddPar = Ord(K_msdMVVectors));
end;

//********************************************** TK_UDMVTable.AddChildToSubTree
//
function TK_UDMVTable.AddChildToSubTree(PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = []): Boolean;
var
  NewVector, NewAttrs, VDir : TN_UDBase;
  BuildUniqAttrsNames : Boolean;
begin
  Result := false;
  if PDE <> nil then
    with PDE^ do begin
      if (Child.CI <> K_UDMVVectorCI) or
         // Object Only in DEClipBoard
         (Child.RefCounter <= 1 ) then Exit;
//         (Child.RefCounter <= 2 ) then Exit;
      if DirLength = 0 then
        Init( TK_PMVVector(TK_UDRArray(Child).R.P)^.CSS )
      else if TK_PMVVector(TK_UDRArray(Child).R.P)^.CSS <> TK_PDSSTable(TK_UDRArray(DirChild(0)).R.P).CSS then Exit;
      NewVector := Child;
      NewAttrs  := Parent.Owner.DirChild(1).DirChild(DirIndex);
      if K_mvcCopyChilds in TK_PCopySubTreeFlags(@CopyPar)^ then
        NewVector := NewVector.Clone;
      if TK_PCopySubTreeFlags(@CopyPar)^ * [K_mvcCopyChilds,K_mvcCopyOwnedChilds] <> [] then
        NewAttrs := NewAttrs.Clone;
      VDir := DirChild(0);
      with VDir do begin
        AddOneChildV( NewVector );
        BuildUniqAttrsNames := VDir <> NewVector.Owner;
        if not BuildUniqAttrsNames then begin
          BuildUniqChildName( '', NewVector );
          NewAttrs.ObjName := NewVector.ObjName;
          if NewVector.ObjAliase <> '' then begin
            BuildUniqChildName( '', NewVector, K_ontObjAliase );
            NewAttrs.ObjAliase := NewVector.ObjAliase;
          end;
        end;
      end;
      VDir := DirChild(1);
      with VDir do begin
        AddOneChildV( NewAttrs );
        if BuildUniqAttrsNames and (VDir = NewAttrs.Owner) then begin
          BuildUniqChildName( '', NewAttrs );
          if NewAttrs.ObjAliase <> '' then
            BuildUniqChildName( '', NewAttrs, K_ontObjAliase );
        end;
      end;
    end;
  Result := true;
end;

//********************************************** TK_UDMVTable.RemoveSelfFromSubTree
//
function TK_UDMVTable.RemoveSelfFromSubTree(PDE: TK_PDirEntryPar): Boolean;
begin
  if PDE = nil then
    Result := true
  else
    with PDE^ do
      Result := K_RemoveMVDarFolderElement( Parent, DirIndex );
end;

//********************************************** TK_UDMVTable.MoveSubTreeChilds
//
procedure TK_UDMVTable.MoveSubTreeChilds( dInd, sInd: Integer; mcount : Integer = 1 );

begin
  if DirLength = 0 then Exit;
  if DirChild(0).MoveEntries( dInd, sInd, mcount ) > 0 then
    DirChild(1).MoveEntries( dInd, sInd, mcount );
end;

//********************************************** TK_UDMVTable.DeleteSubTreeChild
//
function  TK_UDMVTable.DeleteSubTreeChild(Ind : Integer) : Boolean;
begin
  if Ind >= 0 then begin
    DirChild(0).DeleteDirEntry(Ind);
    DirChild(1).DeleteDirEntry(Ind);
  end;
  Result := true;
end;

//********************************************** TK_UDMVTable.GetSubTreeChildDE
//
function TK_UDMVTable.GetSubTreeChildDE(Ind: Integer;
  out DE: TN_DirEntryPar): Boolean;
begin
  Result := DirChild(0).GetSubTreeChildDE(Ind, DE);
end;

//********************************************** TK_UDMVTable.GetSubTreeChildHigh
//
function TK_UDMVTable.GetSubTreeChildHigh: Integer;
begin
  Result := DirChild(0).DirHigh;
end;

//********************************************** TK_UDMVTable.GetUDAttribs
//
function TK_UDMVTable.GetUDAttribs( Ind : Integer ) : TK_UDRArray;
begin
  Result := TK_UDRArray(DirChild(1).DirChild(Ind));
end;

//********************************************** TK_UDMVTable.GetUDVector
//
function TK_UDMVTable.GetUDVector( Ind : Integer ) : TK_UDVector;
begin
  Result := TK_UDVector(DirChild(0).DirChild(Ind));
end;

//********************************************** TK_UDMVTable.IndexOfUDVector
//
function TK_UDMVTable.IndexOfUDVector(UDVector: TN_UDBase): Integer;
begin
  Result := DirChild(0).IndexOfDEField(UDVector);
end;

//********************************************** TK_UDMVTable.GetUDVectorAllSufficientCaption
//  Get Tab UDVector All-Sufficiient Caption which include Table Caption
//
function TK_UDMVTable.GetUDVectorAllSufficientCaption( Ind : Integer ) : string;
begin
  Result := TK_PMVTable(R.P).FullCapt + '<br>'+ GetUDVector( Ind ).ObjAliase;
end;

{*** end of TK_UDMVTable ***}

{*** TK_UDMVWBase ***}

//************************************** TK_UDMVWBase.CanMoveChilds
//  returns True if Node Cane Move Childs
//
function TK_UDMVWBase.CanMoveChilds( ): Boolean;
begin
  Result := true;
end; // end_of function TK_UDMVWBase.CanMoveChilds

//************************************** TK_UDMVWBase.CanMoveDE
//  returns True if Node Cane Move Childs
//
function TK_UDMVWBase.CanMoveDE( const DE : TN_DirEntryPar ) : Boolean;
begin
  Result := true;
end; // end_of function TK_UDMVWBase.CanMoveDE

//************************************** TK_UDMVWBase.CanAddChildByPar
//  returns True if Child specified by AddPar can be added to this Node
//
function TK_UDMVWBase.CanAddChild( Child : TN_UDBase ): Boolean;
begin
  Result := CanAddChildByPar( Ord( K_MVDarGetUserNodeType(Child) ) );
end;

//********************************************** TK_UDMVWBase.AddChildToSubTree
//
function TK_UDMVWBase.AddChildToSubTree(PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ): Boolean;
begin
  Result := K_AddMVChildToSubTree( Self, PDE, CopyPar );
end;

//********************************************** TK_UDMVWBase.DeleteSubTreeChild
//
function TK_UDMVWBase.DeleteSubTreeChild(Index: Integer): Boolean;
begin
  if Index >= 0 then
    DeleteDirEntry(Index);
  Result := true;
end;

//********************************************** TK_UDMVWBase.RemoveSelfFromSubTree
//
function TK_UDMVWBase.RemoveSelfFromSubTree(PDE: TK_PDirEntryPar): Boolean;
begin
  if PDE = nil then
    Result := true
  else
    with PDE^ do begin
      Result := K_RemoveMVDarFolderElement( Parent, DirIndex );
    end;
end;

{*** end of TK_UDMVWBase ***}

{*** TK_UDMVVWindow ***}

//********************************************** TK_UDMVVWindow.Create
//
constructor TK_UDMVVWindow.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVVWindowCI;
  ImgInd := 71;
end;

//********************************************** TK_UDMVVWindow.CanAddChildByPar
//
function TK_UDMVVWindow.CanAddChildByPar( AddPar : Integer): Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdVWFrameSets : Result := true;
  else
    Result := false;
  end;
end;

//********************************************** TK_UDMVVWindow.GetMVVWindows
//
procedure TK_UDMVVWindow.GetMVVWindows( MVVWindowsInfo: TStrings; SaveFrameSets : Boolean );
var
  i,h : Integer;
  UDChild : TN_UDBase;
begin
  MVVWindowsInfo.AddObject( TK_PMVVWindow(R.P).VWName, Self );
  h := DirHigh;
  for i := 0 to h do begin
    UDChild := DirChild(i);
    if UDChild is TK_UDMVVWFrameSet then
      TK_UDMVVWFrameSet(UDChild).GetMVVWFrames( MVVWindowsInfo, nil, SaveFrameSets );
  end;
end;

{*** end of TK_UDMVVWindow ***}

{*** TK_UDMVVWFrame ***}

//********************************************** TK_UDMVVWFrame.Create
//
constructor TK_UDMVVWFrame.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVVWFrameCI;
  ImgInd := 72;
end;

//********************************************** TK_UDMVVWFrame.AddHTMStrings
//
procedure TK_UDMVVWFrame.AddHTMStrings( HTMInfo: TStrings; PreviewMode : Boolean );
var
  Attrs : string;
  str : string;
begin
  with TK_PMVVWFrame(R.P)^ do begin
    Attrs := ' marginwidth='+IntToStr(MarginWidth)+' marginheight='+IntToStr(MarginHeight);
    if K_fmfSkipBorders in ModeFlags.T then
      Attrs := Attrs + ' frameborder=0';
    if K_fmfSkipResize in ModeFlags.T then
      Attrs := Attrs + ' NORESIZE';
    case ScrollMode of
      K_fsmYes : str := 'yes';
      K_fsmNo  : str := 'no';
    else
      str := '';
    end;
    if str <> '' then
      Attrs := Attrs + ' scrolling=' + str;
    if PreviewMode then
      Attrs := Attrs + ' src="javascript:''<html><body><center>'+
             VWName+'</center></body></html>''"';
    HTMInfo.Add('<FRAME name="'+VWName+'"'+Attrs+'>');
  end;
end;

{*** end of TK_UDMVVWFrame ***}

{*** TK_UDMVVWFrameSet ***}

//********************************************** TK_UDMVVWFrameSet.Create
//
constructor TK_UDMVVWFrameSet.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVVWFrameSetCI;
  ImgInd := 73;
end;

//********************************************** TK_UDMVVWFrameSet.CanAddChildByPar
//
function TK_UDMVVWFrameSet.CanAddChildByPar( AddPar : Integer): Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdVWFrames   : Result := true;
    K_msdVWFrameSets : Result := true;
  else
    Result := false;
  end;
end;

//********************************************** TK_UDMVVWFrameSet.AddChildToSubTree
//
function TK_UDMVVWFrameSet.AddChildToSubTree(PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = []): Boolean;
var
  HInd : Integer;
begin
  Result := K_AddMVChildToSubTree( Self, PDE, CopyPar );
  if (PDE = nil) or not Result then Exit;
  with TK_PMVVWFrameSet(R.P)^ do begin
    if ElemsSize = nil then
      ElemsSize := TK_RArray.CreateByType( Ord(nptString) );
    HInd := DirHigh;
    ElemsSize.ASetLength( HInd + 1 );
    PString(ElemsSize.P(HInd))^ := '*';
  end;
end;

//********************************************** TK_UDMVVWFrameSet.DeleteSubTreeChild
//
function TK_UDMVVWFrameSet.DeleteSubTreeChild(Index: Integer): Boolean;
begin
  if Index >= 0 then begin
    DeleteDirEntry(Index);
    with TK_PMVVWFrameSet(R.P)^ do begin
      ElemsSize.DeleteElems(Index);
    end;
  end;
  Result := true;
end;

//********************************************** TK_UDMVVWFrameSet.DeleteSubTreeChild
//
procedure TK_UDMVVWFrameSet.MoveSubTreeChilds(dInd, sInd, mcount: Integer);
begin
  if MoveEntries( dInd, sInd, mcount) = 0 then Exit;
  with TK_PMVVWFrameSet(R.P)^ do
    ElemsSize.MoveElems( dInd, sInd, mcount );
end;

//********************************************** TK_UDMVVWFrameSet.AddHTMStrings
//
procedure TK_UDMVVWFrameSet.AddHTMStrings( HTMInfo: TStrings; PreviewMode : Boolean );
var
  i,h : Integer;
  UDChild : TN_UDBase;
  ListInd : Integer;
  str,Attrs : string;
begin
  ListInd := HTMInfo.Count;
  HTMInfo.Add('');
  h := DirHigh;
  Attrs := '<FRAMESET';
  with TK_PMVVWFrameSet(R.P)^ do begin
    if VName <> '' then
      Attrs := Attrs + ' name="'+VName+'"';
    if K_fsmfSkipBorders in ModeFlags.T then
      Attrs := Attrs + ' frameborder=0';
    if K_fsmfVertical in ModeFlags.T then
      str := ' ROWS="'
    else
      str := ' COLS="';
    Attrs := Attrs + str;
    str := '';
    for i := 0 to h do begin
      UDChild := DirChild(i);
      if not (UDChild is TK_UDMVVWFrame) then Continue;
      Attrs := Attrs + str + PString( ElemsSize.P(i) )^;
      TK_UDMVVWFrame(UDChild).AddHTMStrings( HTMInfo, PreviewMode );
      if str = '' then str := ',';
    end;
  end;
  HTMInfo[ListInd] := Attrs + '">';
  HTMInfo.Add('</FRAMESET>');
end;

//********************************************** TK_UDMVVWFrameSet.GetMVVWFrames
//
procedure TK_UDMVVWFrameSet.GetMVVWFrames( MVVWindowsInfo: TStrings;
                        MainFrameSet : TN_UDBase; SaveFrameSets : Boolean );
var
  i,h : Integer;
  UDChild : TN_UDBase;
  SavedObj : TN_UDBase;
begin
  h := DirHigh;
  if MainFrameSet = nil then MainFrameSet := Self;
  for i := 0 to h do begin
    UDChild := DirChild(i);
    if UDChild is TK_UDMVVWFrameSet then
      TK_UDMVVWFrameSet(UDChild).GetMVVWFrames( MVVWindowsInfo, MainFrameSet, SaveFrameSets )
    else if UDChild is TK_UDMVVWFrame then begin
      if SaveFrameSets then
        SavedObj := MainFrameSet
      else
        SavedObj := UDChild;
      MVVWindowsInfo.AddObject( TK_PMVVWFrame(TK_UDMVVWFrame(UDChild).R.P).VWName, SavedObj );
    end;
  end;
end;

{*** end of TK_UDMVVWFrameSet ***}

{*** TK_UDMVWFolder ***}

//********************************************** TK_UDMVWFolder.Create
//
constructor TK_UDMVWFolder.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWFolderCI;
  ImgInd := 32;
end;

//********************************************** TK_UDMVWFolder.CanAddChildByPar
//
function TK_UDMVWFolder.CanAddChildByPar( AddPar : Integer): Boolean;
begin
  Result := K_CanAddToMVWFolder( AddPar );
end;

//********************************************** TK_UDMVWFolder.AddChildToSubTree
//
function TK_UDMVWFolder.AddChildToSubTree(PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = []): Boolean;
var
  HInd : Integer;
begin
  Result := K_AddMVChildToSubTree( Self, PDE, CopyPar, K_msdWebFolder );
  if (PDE <> nil) and Result then
    with PDE^ do
      with TK_PMVWebFolder(R.P)^ do
        if (WENType.T = K_gecWEParent) or (WECapts <> nil) then begin
          if WECapts = nil then
            WECapts := TK_RArray.CreateByType( Ord(nptString) );
          HInd := DirHigh;
          WECapts.ASetLength(HInd + 1);
          PString(WECapts.P(HInd))^ := Child.ObjAliase;
        end;
end;

//********************************************** TK_UDMVWFolder.DeleteSubTreeChild
//
procedure TK_UDMVWFolder.MoveSubTreeChilds(dInd, sInd, mcount: Integer);
begin
  if MoveEntries( dInd, sInd, mcount) = 0 then Exit;
  with TK_PMVWebFolder(R.P)^ do
    if (WENType.T = K_gecWEParent) or (WECapts <> nil) then
      WECapts.MoveElems( dInd, sInd, mcount );
end;

//********************************************** TK_UDMVWFolder.DeleteSubTreeChild
//
function TK_UDMVWFolder.DeleteSubTreeChild(Index: Integer): Boolean;
begin
  if Index >= 0 then begin
    with TK_PMVWebFolder(R.P)^ do
      if (WENType.T = K_gecWEParent) or (WECapts <> nil) then begin
        WECapts.ASetLength(DirLength);
        WECapts.DeleteElems(Index);
      end;
    DeleteDirEntry(Index);
  end;
  Result := true;
end;

{*** end of TK_UDMVWFolder ***}

{*** TK_UDMVWVTreeWin ***}

//********************************************** TK_UDMVWVTreeWin.Create
//
constructor TK_UDMVWVTreeWin.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWVTreeWinCI;
  ImgInd := 60;
end;

//********************************************** TK_UDMVWVTreeWin.CanAddChildByPar
//
function TK_UDMVWVTreeWin.CanAddChildByPar(AddPar : Integer): Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdWebFolder : Result := true;
  else
    Result := false;
  end;
end;

//********************************************** TK_UDMVWVTreeWin.AddChildToSubTree
//
function TK_UDMVWVTreeWin.AddChildToSubTree( PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ): Boolean;
var
  ObjSysType : TK_MVDARSysType;
begin
  Result := false;
  if PDE <> nil then
    with PDE^ do begin
      ObjSysType := K_MVDarGetUserNodeType( Child );
      if CanAddChildByPar( Ord( ObjSysType ) ) then begin
        if (K_mvcCopyChildRefs in TK_PCopySubTreeFlags(@CopyPar)^) or
           (K_mvcCopyFolders in TK_PCopySubTreeFlags(@CopyPar)^)    or
           ( (K_mvcCopyOwnedChilds in CopyPar) and
             (Parent <> Child.Owner) )  then
          CopyPar := []; // Skip Subtree Copy
        Child := Child.SelfCopy( CopyPar );
        if DirLength = 0 then
          AddOneChildV( Child )
        else
          PutDirChildV( 0, Child );
        K_SetChildUniqNames( Self, Child, ObjSysType );
        with TK_PMVWebFolder(TK_UDRArray(Child).R.P)^ do begin
          TK_PMVWebVTreeWin(R.P).FullCapt  := FullCapt;   // Web Object Full Caption
          TK_PMVWebVTreeWin(R.P).BriefCapt := BriefCapt;  // Web Object Brief Caption
        end;
      end else Exit;
    end;
  Result := true;
end;

{*** end of TK_UDMVWVTreeWin ***}

{*** TK_UDMVWMSTabWin ***}

//********************************************** TK_UDMVWMSTabWin.CanAddChildByPar
//
function TK_UDMVWMSTabWin.CanAddChildByPar( AddPar : Integer): Boolean;
begin
  Result := (AddPar = Ord(K_msdBTables));
end;

//********************************************** TK_UDMVWMSTabWin.AddChildToSubTree
//
function TK_UDMVWMSTabWin.AddChildToSubTree( PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ): Boolean;
var
  HInd,i : Integer;
begin
  Result := K_AddMVChildToSubTree( Self, PDE, CopyPar );
  if (PDE <> nil) and Result then
    with PDE^ do
      with TK_PMVWebMSTabWin(R.P)^ do begin
        if Sections = nil then
          Sections := TK_RArray.CreateByType( K_GetTypeCodeSafe('TK_MVWebSection').All );
        HInd := DirHigh;
        Sections.ASetLength(HInd + 1);
        with TK_PMVWebSection(Sections.P(HInd))^ do begin
          Caption := Child.ObjAliase;
          WENType := ASWENType;
          if WENType.T = K_gecWEParent then
            with Child.DirChild(0) do begin
              HInd := DirHigh;
              //*** Init WEBTable VCSS
              if (VCSS = nil) and (HInd >= 0) then
                K_SetUDRefField( VCSS, TK_PMVVector(TK_UDRArray(DirChild(0)).R.P).CSS );
              WECapts := TK_RArray.CreateByType( Ord(nptString), HInd + 1 );
              for i := 0 to DirHigh do
                PString(WECapts.P(i))^ := DirChild(i).ObjAliase;
            end;
        end;
      end;
end;

//********************************************** TK_UDMVWMSTabWin.DeleteSubTreeChild
//
function TK_UDMVWMSTabWin.DeleteSubTreeChild(Index: Integer): Boolean;
begin
  if Index >= 0 then begin
    DeleteDirEntry(Index);
    with TK_PMVWebMSTabWin(R.P)^ do begin
      Sections.DeleteElems(Index);
      if DirLength = 0 then
        K_SetUDRefField( VCSS, nil ); // free
    end;
  end;
  Result := true;
end;

//********************************************** TK_UDMVWMSTabWin.DeleteSubTreeChild
//
procedure TK_UDMVWMSTabWin.MoveSubTreeChilds(dInd, sInd, mcount: Integer);
begin
  if MoveEntries( dInd, sInd, mcount) = 0 then Exit;
  with TK_PMVWebMSTabWin(R.P)^ do
    Sections.MoveElems( dInd, sInd, mcount );
end;

//********************************************** TK_UDMVWMSTabWin.CanAddOwnChildByPar
//
function TK_UDMVWMSTabWin.CanAddOwnChildByPar( CreatePar: Integer ): Boolean;
begin
  Result := false;
end;

{*** end of TK_UDMVWMSTabWin ***}

{*** TK_UDMVWLDiagramWin ***}

//********************************************** TK_UDMVWLDiagramWin.Create
//
constructor TK_UDMVWLDiagramWin.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWLDiagramWinCI;
  ImgInd := 61;
end;

{*** end of TK_UDMVWLDiagramWin ***}

{*** TK_UDMVWTableWin ***}

//********************************************** TK_UDMVWTableWin.Create
//
constructor TK_UDMVWTableWin.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWTableWinCI;
  ImgInd := 62;
end;

{*** end of TK_UDMVWTableWin ***}



{*** TK_UDMVWWinGroup ***}

//********************************************** TK_UDMVWWinGroup.Create
//
constructor TK_UDMVWWinGroup.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWWinGroupCI;
  ImgInd := 69;
end;

function TK_UDMVWWinGroup.CanAddChildByPar( AddPar : Integer): Boolean;
begin
  Result := K_CanAddToMVWFolder( AddPar );
  if Result then
    case TK_MVDARSysType(AddPar) of
      K_msdWebWinGroups,
      K_msdWebFolder : Result := false;
    end;
end;

//********************************************** TK_UDMVWWinGroup.AddChildToSubTree
//
function TK_UDMVWWinGroup.AddChildToSubTree(PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = []): Boolean;
var
  HInd : Integer;
  PMVWebWinObj : TK_PMVWebWinObj;

begin
  Result := K_AddMVChildToSubTree( Self, PDE, CopyPar );
  if (PDE <> nil) and Result then
    with PDE^ do
      with TK_PMVWebWinGroup(R.P)^ do begin
        if WGEAttribs = nil then
          WGEAttribs := TK_RArray.CreateByType( K_GetTypeCodeSafe('TK_MVWebWinGroupElem').All );
        HInd := DirHigh;
        WGEAttribs.ASetLength(HInd + 1);

        case TK_MVDARSysType(K_MVDarGetUserNodeType( Child )) of
          K_msdWebVHTMWins,
          K_msdWebVHTMRefWins :
          PMVWebWinObj := TK_PMVWebWinObj(@(TK_PMVWebVHTMWin(TK_UDRArray(Child).R.P).FullCapt));
        else
          PMVWebWinObj := TK_PMVWebWinObj(TK_UDRArray(Child).R.P);
        end;

        with TK_PMVWebWinGroupElem(WGEAttribs.P(HInd))^,
             PMVWebWinObj^ do begin
          EERGName  := ERGName;   // Events Recipient Group Name
          EVWinName  := VWinName; // Virtual Window Name
        end;

      end;
end;

//********************************************** TK_UDMVWWinGroup.DeleteSubTreeChild
//
function TK_UDMVWWinGroup.DeleteSubTreeChild(Index: Integer): Boolean;
begin
  if Index >= 0 then begin
    DeleteDirEntry(Index);
    with TK_PMVWebWinGroup(R.P)^ do begin
      WGEAttribs.DeleteElems(Index);
    end;
  end;
  Result := true;
end;

//********************************************** TK_UDMVWWinGroup.DeleteSubTreeChild
//
procedure TK_UDMVWWinGroup.MoveSubTreeChilds(dInd, sInd, mcount: Integer);
begin
  if MoveEntries( dInd, sInd, mcount) = 0 then Exit;
  with TK_PMVWebWinGroup(R.P)^ do
    WGEAttribs.MoveElems( dInd, sInd, mcount );
end;

{*** end of TK_UDMVWWinGroup ***}


{*** TK_UDMVWHTMWin ***}

//********************************************** TK_UDMVWHTMWin.Create
//
constructor TK_UDMVWHTMWin.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWHTMWinCI;
  ImgInd := 63;
end;

{*** end of TK_UDMVWHTMWin ***}

{*** TK_UDMVWVHTMWin ***}

//********************************************** TK_UDMVWVHTMWin.Create
//
constructor TK_UDMVWVHTMWin.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWVHTMWinCI;
  ImgInd := 65;
end;

//********************************************** TK_UDMVWVHTMWin.RemoveSelfFromSubTree
//
function TK_UDMVWVHTMWin.RemoveSelfFromSubTree( PDE: TK_PDirEntryPar): Boolean;
begin
  if PDE = nil then
    Result := true
  else
    with PDE^ do
      Result := K_RemoveMVDarFolderElement( Parent, DirIndex );
end;

{*** end of TK_UDMVWVHTMWin ***}

{*** TK_UDMVWSite ***}

//********************************************** TK_UDMVWSite.Create
//
constructor TK_UDMVWSite.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVWSiteCI;
  ImgInd := 26;
end;

//********************************************** TK_UDMVWSite.CanAddChildByPar
//
function TK_UDMVWSite.CanAddChildByPar(AddPar: Integer): Boolean;
begin
  case TK_MVDARSysType(AddPar) of
    K_msdWebVTreeWins, K_msdWebTableWins, K_msdWebLDiagramWins,
    K_msdWebWinGroups, K_msdWebHTMWins, K_msdWebHTMRefWins,
    K_msdWebVHTMWins, K_msdWebVHTMRefWins, K_msdWebCartWins,
    K_msdWebCartGroupWins : Result := true;
  else
    Result := false;
  end;
end;

//********************************************** TK_UDMVWSite.AddChildToSubTree
//
function TK_UDMVWSite.AddChildToSubTree( PDE: TK_PDirEntryPar; CopyPar : TK_CopySubTreeFlags = [] ): Boolean;
var
  ObjSysType : TK_MVDARSysType;
begin
  Result := false;
  if PDE <> nil then
    with PDE^ do begin
      ObjSysType := K_MVDarGetUserNodeType( Child );
      if CanAddChildByPar( Ord( ObjSysType ) ) then begin
        if (K_mvcCopyChildRefs in TK_PCopySubTreeFlags(@CopyPar)^) or
           (K_mvcCopyFolders in TK_PCopySubTreeFlags(@CopyPar)^)    or
           ( (K_mvcCopyOwnedChilds in CopyPar) and
             (Parent <> Child.Owner) ) then
          CopyPar := []; // Skip Subtree Copy
        Child := Child.SelfCopy( CopyPar );
        if DirLength = 0 then
          AddOneChildV( Child )
        else
          PutDirChildV( 0, Child );
        K_SetChildUniqNames( Self, Child, ObjSysType );
        if ObjSysType = K_msdWebVTreeWins then
          with TK_PMVWebVTreeWin(TK_UDRArray(Child).R.P)^ do begin
            TK_PMVWebSite(R.P).Title := Title;
            K_SetUDRefField( TK_PMVWebSite(R.P).UDWLayout, UDWLayout );
            K_SetUDRefField( TK_PMVWebSite(R.P).UDWWinObj, UDWWinObj );
          end
        else if ObjSysType = K_msdWebWinGroups then
          with TK_PMVWebWinGroup(TK_UDRArray(Child).R.P)^ do
            TK_PMVWebSite(R.P).Title := Title
        else if Child is TK_UDMVWVHTMWin then
          with TK_PMVWebVHTMWin(TK_UDRArray(Child).R.P)^ do begin
            TK_PMVWebSite(R.P).Title := Title;
            TK_PMVWebSite(R.P).VWinName := VWinName;
          end
        else
          with TK_PMVWebWinObj(TK_UDRArray(Child).R.P)^ do begin
            TK_PMVWebSite(R.P).Title := Title;
            TK_PMVWebSite(R.P).VWinName := VWinName;
          end;
      end else Exit;
    end;
  Result := true;
end;

{*** end of TK_UDMVWSite ***}

//*************************************** K_GetDSSTableDType
// Get Data SubSpace Linked Vector record Type Code
//
function  K_GetMVTableDType() : TK_ExprExtType;
begin
  if K_MVTableDType.All = 0 then
    K_MVTableDType := K_GetTypeCodeSafe('TK_MVTable');
  Result := K_MVTableDType;
end; //*** end of function K_GetDSSTableDType

{*** TK_RAFMVTabViewer ***}

//**************************************** TK_RAFMVTabViewer.GetText
//
//
function TK_RAFMVTabViewer.GetText(var Data; var RAFC: TK_RAFColumn; ACol,
  ARow: Integer; PHTextPos : Pointer = nil ): string;
var
  i : Integer;
  RASV : TK_RArray;
begin
  SetTextShift;
//  i := K_GetSpecValueInd( Double(Data), K_CurMVSpecVals );
  RASV := TK_RArray(RAFC.RUDInfo);
//  if RASV = nil then RASV := K_CurMVSpecVals;
  i := K_GetSpecValueInd( Double(Data), RASV );

  if i >= 0 then
//    with TK_PMVDataSpecVal( K_CurMVSpecVals.P(i) )^ do
    with TK_PMVDataSpecVal( RASV.P(i) )^ do
      Result := Caption
  else
    Result := inherited GetText(Data, RAFC, ACol, ARow, PHTextPos );
end;

{*** end of TK_RAFMVTabViewer ***}

{*** TK_RAFMVTabEditor ***}

//**************************************** TK_RAFMVTabEditor.Destroy
//
destructor TK_RAFMVTabEditor.Destroy;
begin
  CmB.Free;
  inherited;
end; //*** destructor TK_RAFMVTabEditor.Destroy

//**************************************** TK_RAFMVTabEditor.Edit
//
function TK_RAFMVTabEditor.Edit(var Data ) : Boolean;
var
  GRect : TRect;
//  i, h : Integer;
begin
  Result := false;
  if CmB = nil then begin
    CmB := TComboBox.Create( RAFRame.Owner );
    CmB.Parent := RAFrame;
//    CmB.Items.AddStrings(K_MVSVList);
    CmB.Style := csDropDown;
    CmB.OnKeyDown := OnKeyDownH;
    CmB.OnExit := OnExitH;
  end;

  CmB.Items.Clear;

//  K_InitMVSpecValsList( K_CurMVSpecVals, CmB.Items);
  with RAFRame do
    SVArr := TK_RArray(RAFCArray[CurLCol].RUDInfo);
//  if SVArr = nil then SVArr := K_CurMVSpecVals;
  K_InitMVSpecValsList( SVArr, CmB.Items);

  with CmB do begin
    ECol := RAFRame.CurGCol;
    ERow := RAFRame.CurGRow;
    GRect := RAFRame.SGrid.CellRect(ECol, ERow);
    Top := GRect.Top + 2;
    Left := GRect.Left + 3;
    Width := GRect.Right - GRect.Left;
//    ItemIndex := K_GetSpecValueInd( Double(Data), K_CurMVSpecVals );
    ItemIndex := K_GetSpecValueInd( Double(Data), SVArr );
    if ItemIndex < 0 then
      Text := K_ToString( Data, K_isDouble );
    Visible := true;
    SetFocus;
    PData := PDouble(@Data);
  end;
end; //*** procedure TK_RAFMVTabEditor.Edit

//**************************************** TK_RAFMVTabEditor.OnExitH
//  OnExit Handler
//
procedure TK_RAFMVTabEditor.OnExitH(Sender: TObject);
begin
  CmB.Visible := false;
end; //*** procedure TK_RAFMVTabEditor.OnExitH

//**************************************** TK_RAFMVTabEditor.SetResult
//
procedure TK_RAFMVTabEditor.SetResult( );
begin
  with CmB do begin
    if ItemIndex <> -1 then
//      PData^ := TK_PMVDataSpecVal( K_CurMVSpecVals.P(ItemIndex) ).Value
      PData^ := TK_PMVDataSpecVal( SVArr.P(ItemIndex) ).Value
    else
      K_SPLValueFromString( PData^, Ord(nptDouble ), Text );
  end;
  with RAFRame do if Assigned(OnDataChange) then OnDataChange();
end;

//**************************************** TK_RAFMVTabEditor.OnKeyDownH
//  OnKeyDown Handler
//
procedure TK_RAFMVTabEditor.OnKeyDownH( Sender: TObject; var Key: Word;
  Shift: TShiftState );
var
  SelRect: TGridRect;
  FinishEdit : Boolean;
  procedure SetSelection( D : Integer );
  begin
    SelRect.Left := ECol;
    SelRect.Right := ECol;
    SelRect.Top := ERow + D;
    SelRect.Bottom := SelRect.Top;
    RAFRame.SGrid.Selection := SelRect;
    RAFRame.SetCurLPos( SelRect.Left, SelRect.Top );
  end;

  procedure ASetResult( );
  begin
    SetResult( );
    FinishEdit := true;
  end;

begin
  FinishEdit := false;
  case Key of
  VK_RETURN:
    ASetResult;
  VK_ESCAPE:
    FinishEdit := true;
  VK_UP:
    if not(ssShift in Shift) then begin
      ASetResult;
      SetSelection( -1 );
    end;
  VK_DOWN:
    if not(ssShift in Shift) then begin
      ASetResult;
      SetSelection( 1 );
    end;
  end;
  if not FinishEdit then Exit;
  CmB.Visible := false;
  RAFRame.SGrid.SetFocus;
end; //*** procedure TK_RAFMVTabEditor.OnKeyDownH

{*** end of TK_RAFMVTabEditor ***}

{*** TK_RAMVVWinNameEditor ***}

constructor TK_RAMVVWinNameEditor.Create;
begin
  inherited;
  SFilter.AddItem( TK_UDFilterClassSect.Create( K_UDMVVWFrameCI ) );
  SFilter.AddItem( TK_UDFilterClassSect.Create( K_UDMVVWindowCI ) );
end;

function TK_RAMVVWinNameEditor.Edit(var Data): Boolean;
var
  WN : TN_UDBase;
//  RPath : string;
  SL : TStrings;
  VWN : string;
  NInd : Integer;
  SelRes : Boolean;
begin

  if UDTS.FPrevRootUDNode = nil then begin //*** Build Root
    if (UDTS.FRootPath <> '') and  (UDTS.FRootPath <> K_udpAbsPathCursorName) then
      UDTS.FPrevRootUDNode := K_UDCursorGetObj( UDTS.FRootPath );
    if UDTS.FPrevRootUDNode = nil then UDTS.FPrevRootUDNode := K_CurArchive;
    if UDTS.FPrevRootUDNode = nil then begin
      if UDTS.FRootPath = K_udpAbsPathCursorName then
        UDTS.FPrevRootUDNode := K_MainRootObj
      else
       UDTS.FPrevRootUDNode := K_ArchsRootObj;
    end;
  end;

  VWN := string(Data);
  WN := nil;
//  RPath := '';
  if (VWN <> '') and
     (UDTS.FPrevRootUDNode <> nil) and
     (UDTS.FPrevRootUDNode is TK_UDMVVWLayout) then begin
//*** Build path to UDObj
    SL := TStringList.Create;
    TK_UDMVVWLayout(UDTS.FPrevRootUDNode).GetMVVWindowList( SL, false );
    NInd := SL.IndexOf(VWN);
    if NInd >= 0 then begin
      WN := TN_UDBase(SL.Objects[NInd]);
//      RPath := UDTS.FPrevRootUDNode.GetPathToObj( WN );
    end;
    SL.Free;
  end;

  with RAFrame do begin

    UDTS.FSelectFFunc := SFilter.UDFTest;
    SelRes := UDTS.SelectUDB( WN, nil, RAFRame.RAFCArray[RAFRame.CurLCol].Caption );

//    WN := K_SelectUDB( UDTS.FPrevRootUDNode, RPath, SFilter.UDFTest, TN_UDBase( 1 ),
//            RAFRame.RAFCArray[RAFRame.CurLCol].Caption );
//    SelRes := Integer(WN) <> 1
    if not SelRes                    or
       ( not (WN is TK_UDMVVWFrame) and
         not (WN is TK_UDMVVWindow) ) then
      Result := false
    else begin
      if WN = nil then
        string(Data) := ''
      else begin
        string(Data) := TK_PMVVWindow(TK_UDMVVWindow(WN).R.P).VWName;
{
        while (WN is TK_UDMVVWFrame) or
              (WN is TK_UDMVVWFrameSet) or
              (WN is TK_UDMVVWindow) do WN := WN.Owner;
        UDTS.FPrevRootUDNode := WN;
}
      end;
      Result := true;
    end;
  end;
end;
{*** end of TK_RAMVVWinNameEditor ***}

{*** TK_SpecValsAssistant ***}

constructor TK_SpecValsAssistant.Create( ARASV: TK_RArray );
var
  i : Integer;
  PSV : TK_PMVDataSpecVal;
begin
  inherited Create;
  RASV := ARASV.AAddRef;
  PScale := @(TK_PMVDataSpecVal(RASV.P).Value);
  ScaleStep := RASV.ElemSize;
  ScaleHigh := RASV.AHigh;
  for i := 0 to ScaleHigh do begin
    PSV := TK_PMVDataSpecVal(RASV.P(i));
    with PSV^ do
      if Value = 0.0 then Value := Sign(IVNum)*(Abs(IVNum) + 1) * K_MVMaxVal;
  end;
end;

destructor TK_SpecValsAssistant.Destroy;
begin
  RASV.ARelease;
  inherited;
end;

function TK_SpecValsAssistant.GetSpecValAttrs( ValInd : Integer ): TK_PMVDataSpecVal;
begin
  if (ValInd < 0) or (ValInd > ScaleHigh) then ValInd := ScaleHigh;
  Result := TK_PMVDataSpecVal( RASV.P(ValInd) );
end;

function TK_SpecValsAssistant.IndexOfSpecVal(Val: Double): Integer;
var i : Integer;
begin
  Result := -1;
  if ( K_MVMinVal > Val ) or
     ( K_MVMaxVal < Val ) then
    for i := 0 to ScaleHigh do
      if TK_PMVDataSpecVal(RASV.P(i)).Value = Val then Result := i;
end;

function TK_SpecValsAssistant.IndexOfSpecVal(Capt: string): Integer;
var i : Integer;
begin
  Result := -1;
  for i := 0 to ScaleHigh do
    if TK_PMVDataSpecVal(RASV.P(i)).Caption = Capt then Result := i;
end;

procedure TK_SpecValsAssistant.GetSpecValStrings(SL: TStrings);
var i : Integer;
begin
  SL.Clear;
  for i := 0 to ScaleHigh do
    SL.Add( TK_PMVDataSpecVal(RASV.P(i)).Caption );

end;


{*** end of TK_SpecValsAssistant ***}


{*** TK_MVValConv ***}

//**************************************** TK_MVValConv.Create
//
constructor TK_MVValConv.Create;
begin
  ML := TStringList.Create;
  ML.Add('Units=');
  ML.Add('Name=');
  ML.Add('Range=');
  ML.Add('Value=');
end; //*** end of constructor TK_MVValConv.Create

//**************************************** TK_MVValConv.Destroy
//
destructor TK_MVValConv.Destroy;
begin
  ML.Free;
  SVA.Free;
  inherited;
end; //*** end of destructor TK_MVValConv.Destroy

//**************************************** TK_MVValConv.GetValColor
//
function TK_MVValConv.GetValColor : Integer;
begin
  if CVInd < 0 then // Spec Value
    Result := SVA.GetSpecValAttrs( -CVInd + 1 ).Color
  else          // Ordinary Value
    Result := PInteger( PMVVAttrs.RangeColors.P(CVInd) )^;
end; //*** end of function TK_MVValConv.GetValColor

//**************************************** TK_MVValConv.GetValText
//
function TK_MVValConv.GetValText( AValName : string = '' ) : string;
var
  RangeText : string;
begin
  with PMVVAttrs^ do begin
    ML[1] := 'Name='+AValName;
    if CVInd < 0 then // Spec Value
      RangeText := SVA.GetSpecValAttrs( -CVInd + 1 ).Caption
    else     // Ordinary Value
      RangeText := PString(RangeCaptions.P(CVInd))^;
    ML[2] := 'Range='+RangeText;
    if CVInd >= 0 then begin // Ordinary  Value
      if VFormat <> '' then
        RangeText := format( VFormat, [CVal])
      else
        RangeText := format('%.*f', [VDPPos, CVal]);
    end;
    ML[3] := 'Value='+RangeText;
    Result := K_StringMListReplace( PureValToTextPat, ML, K_ummRemoveMacro );
  end;
end; //*** end of function TK_MVValConv.GetValText

//**************************************** TK_MVValConv.GetNamedValText
//
function TK_MVValConv.GetNamedValText( AValName : string = '' ) : string;
var
  RangeText : string;
begin
  with PMVVAttrs^ do begin
    ML[1] := 'Name='+AValName;
    if CVInd < 0 then // Spec Value
      RangeText := SVA.GetSpecValAttrs( -CVInd + 1 ).Caption
    else     // Ordinary Value
      RangeText := PString(RangeCaptions.P(CVInd))^;
    ML[2] := 'Range='+RangeText;
    if CVInd >= 0 then begin // Ordinary  Value
      if VFormat <> '' then
        RangeText := format( VFormat, [CVal])
      else
        RangeText := format('%.*f', [VDPPos, CVal]);
    end;
    ML[3] := 'Value='+RangeText;
    Result := K_StringMListReplace( NamedValToTextPat, ML, K_ummRemoveMacro );
  end;
end; //*** end of function TK_MVValConv.GetValText

//**************************************** TK_MVValConv.RebuildMVAttribs
//
procedure TK_MVValConv.RebuildMVAttribs( PData : PDouble; DStep, DCount : Integer;
          ColorSchemeInd : Integer = -1; AColorSchemes : TK_RArray = nil;
          PIndex : PInteger = nil; ICount : Integer = 0 );
begin
  K_RebuildMVAttribs( PMVVAttrs^, PData, DStep, DCount,
                      ColorSchemeInd, AColorSchemes, PIndex, ICount );
end; //*** end of function TK_MVValConv.RebuildMVAttribs

//**************************************** TK_MVValConv.SetCurValue
//
procedure TK_MVValConv.SetCurValue( AVal : Double );
begin
//  CVInd < 0  - SpecialValues Index - 1
//  CVInd >= 0 - RangeColors Index
  CVal := AVal;
  with PMVVAttrs^ do begin
    CVInd := SVA.IndexOfSpecVal( CVal );
    if CVInd >= 0 then begin
//*** Spec Value
      CVInd := -CVInd - 1;
    end else begin
//*** Not Spec Value
      CVInd := K_IndexOfDoubleInScale( PScale, ScaleHigh, sizeof(Double), CVal );
      if (CVInd > 0) and (ValueType.T = K_vdtDiscrete) then Dec(CVInd);
    end;
  end;
end; //*** end of function TK_MVValConv.SetCurValue

//**************************************** TK_MVValConv.SetMVVAttrs
//
procedure TK_MVValConv.SetMVVAttrs( APMVVAttrs : TK_PMVVAttrs = nil );
var
  RASV : TK_RArray;
begin
  if APMVVAttrs = nil then APMVVAttrs := @MVVAttrs;
  PMVVAttrs := APMVVAttrs;
  K_RebuildMVAttribs( PMVVAttrs^, nil, 0, 0 );
  FreeAndNil( SVA );
  with PMVVAttrs^ do begin
    if UDSVAttrs <> nil then
      RASV := TK_UDRArray(UDSVAttrs).R
    else
      RASV := K_CurMVSpecVals;
    SVA := TK_SpecValsAssistant.Create( RASV );
    PScale := PDouble(RangeValues.P);
    ScaleHigh := RangeValues.AHigh;
  end;
end; //*** end of function TK_MVValConv.SetMVVAttrs

//**************************************** TK_MVValConv.SetUnits
//
procedure TK_MVValConv.SetUnits( Units: string );
begin
  ML[0] := 'Units='+Units;
end; //*** end of function TK_MVValConv.SetUnits

{*** end of TK_MVValConv ***}


//********************************************** TK_UDMVCorPict.Create
//
constructor TK_UDMVCorPict.Create;
begin
  inherited;
  ClassFlags := (ClassFlags and K_ClassTypeMask) or K_UDMVCorPictCI;
  ImgInd := 28;
end; //*** end of TK_UDMVCorPict.Create

//********************************************** TK_UDMVCorPict.Init
//
procedure TK_UDMVCorPict.Init(  );
var
  UDB : TN_UDBase;
begin
  if DirChild(0) <> nil then Exit;
  UDB := AddOneChild( TN_UDBase.Create );
  UDB.ObjName := 'Vectors';
  UDB.ObjAliase := 'Вектора';
  AddChildVnodes(0);
  UDB := AddOneChild( TN_UDBase.Create );
  UDB.ObjName := 'Attribs';
  UDB.ObjAliase := 'Атрибуты';
  AddChildVnodes(1);
end; //*** end of TK_UDMVCorPict.TK_UDMVCorPict.Init


//********************************************** TK_UDMVTable.MoveSubTreeChilds
//
procedure TK_UDMVCorPict.MoveSubTreeChilds( dInd, sInd: Integer; mcount : Integer = 1 );

begin
  if DirLength = 0 then Exit;
  if DirChild(0).MoveEntries( dInd, sInd, mcount ) > 0 then
    DirChild(1).MoveEntries( dInd, sInd, mcount );
end;

//********************************************** TK_UDMVCorPict.DeleteSubTreeChild
//
function  TK_UDMVCorPict.DeleteSubTreeChild(Ind : Integer) : Boolean;
begin
  if Ind >= 0 then begin
    DirChild(0).DeleteDirEntry(Ind);
    DirChild(1).DeleteDirEntry(Ind);
  end;
  Result := true;
end;

//********************************************** TK_UDMVCorPict.GetSubTreeChildDE
//
function TK_UDMVCorPict.GetSubTreeChildDE(Ind: Integer;
  out DE: TN_DirEntryPar): Boolean;
begin
  Result := DirChild(0).GetSubTreeChildDE(Ind, DE);
end;

//********************************************** TK_UDMVCorPict.GetSubTreeChildHigh
//
function TK_UDMVCorPict.GetSubTreeChildHigh: Integer;
begin
  Result := DirChild(0).DirHigh;
end;

//********************************************** TK_UDMVCorPict.GetUDAttribs
//
function TK_UDMVCorPict.GetUDAttribs( Ind : Integer ) : TK_UDRArray;
begin
  Result := TK_UDRArray(DirChild(1).DirChild(Ind));
end;

//********************************************** TK_UDMVCorPict.GetUDVector
//
function TK_UDMVCorPict.GetUDVector( Ind : Integer ) : TK_UDVector;
begin
  Result := TK_UDVector(DirChild(0).DirChild(Ind));
end;

//********************************************** TK_UDMVCorPict.IndexOfUDVector
//
function TK_UDMVCorPict.IndexOfUDVector(UDVector: TN_UDBase): Integer;
begin
  Result := DirChild(0).IndexOfDEField(UDVector);
end;

{*** end of TK_UDMVCorPict ***}

{*** TK_MVCorPictUDMVVectorFilterItem ***}

//********************************************** TK_MVCorPictUDMVVectorFilterItem.UDFITest
//
function TK_MVCorPictUDMVVectorFilterItem.UDFITest( const DE: TN_DirEntryPar): Boolean;
var
  ObjCI : Integer;
  UDMVVector : TN_UDBase;
begin
  Result := (DE.Child <> nil);
  if Result then begin
    if K_MVCorPictUDMVVectorFilterUDCS = nil then Exit;
    UDMVVector := DE.Child;
    ObjCI := UDMVVector.CI;
    if ObjCI = K_UDMVWCartWinCI then
      UDMVVector := TK_UDMVWCartWin(UDMVVector).GetLayerUDVector(0);
    Result := TK_UDMVVector(UDMVVector).GetDCSSpace.GetDCSpace = K_MVCorPictUDMVVectorFilterUDCS;
  end;
end; //*** end of TK_MVCorPictUDMVVectorFilterItem.UDFITest
{*** end of TK_MVCorPictUDMVVectorFilterItem ***}

{*** TK_RAFMVCorPictUDMVVectorEditor ***}

//********************************************** TK_RAFMVCorPictUDMVVectorEditor.Edit
//
function TK_RAFMVCorPictUDMVVectorEditor.Edit(var Data): Boolean;
var
  ObjCI : Integer;
  UDMVVector : TN_UDBase;
  UDMVAttrs : TN_UDBase;
  CountUDRef : Boolean;
begin
  with TK_PMVCorPictVector(@Data)^ do begin
    if (K_CPUDMVVExpandedList <> nil)     and
       (UDTS.FExpandedPathList.Count = 0) and
       (TN_UDBase(Data) = nil) then
      UDTS.FExpandedPathList.Assign( K_CPUDMVVExpandedList );
    UDMVVector := UDV;
    Result := inherited Edit( UDV );
    if K_CPUDMVVExpandedList = nil then begin
      K_CPUDMVVExpandedList := TStringList.Create;
      K_CPUDMVVExpandedList.Assign( UDTS.FExpandedPathList );
    end;
    if not Result or (UDV = nil) or (UDMVVector = UDV) then Exit;
    with RAFrame, RAFCArray[CurLCol] do
      CountUDRef := (K_GetExecDataTypeCode(UDV, CDType ).D.CFlags and K_ccCountUDRef) <> 0;

    UDMVVector := UDV;
    ObjCI := UDMVVector.CI;
    if ObjCI = K_UDMVVectorCI then
      with UDTS.FSelectedDE do
        UDMVAttrs := Parent.Owner.DirChild(1).DirChild(DirIndex)
    else begin
      K_SetUDRefField( UDV, TK_UDMVWCartWin(UDMVVector).GetLayerUDVector(0), CountUDRef );
      UDMVAttrs  := TK_UDMVWCartWin(UDMVVector).GetLayerUDVAttrs(0);
    end;
    VCaption := UDV.ObjAliase;
    K_SetUDRefField( UDVA, UDMVAttrs, CountUDRef );
  end;
//  K_SetUDRefField( TK_PMVCorPictVector(@Data).UDVA, UDMVAttrs );
//  TK_PMVCorPictVector(@Data).UDVA := UDMVAttrs;

end; //*** end of TK_RAFMVCorPictUDMVVectorEditor.Edit

//********************************************** TK_RAFMVCorPictUDMVVectorEditor.SetContext
//
procedure TK_RAFMVCorPictUDMVVectorEditor.SetContext( const Data );
var
  CHigh, i : Integer;
begin
  inherited;

  SFilter.AddItem( TK_MVCorPictUDMVVectorFilterItem.Create() );
  CHigh := SFilter.Count - 2;
  for i := CHigh downto 1 do
    SFilter.Insert( i, TK_MVCorPictUDMVVectorFilterItem.Create() );

end; //*** end of TK_RAFMVCorPictUDMVVectorEditor.SetContext

{***  end of TK_RAFMVCorPictUDMVVectorEditor ***}

end.
