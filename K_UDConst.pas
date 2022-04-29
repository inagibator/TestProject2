unit K_UDConst;

interface

//***** Node fields Text unload mode
type TK_TextModeFlags = Set of (
  K_txtMetaFullMode,     // serialize all TN_UDBase fields
  K_txtAttrNewLine,      // each TAG atribute start from new line
  K_txtSkipDblNewLine,   // ignore duplicated NEW_LINE commands
  K_txtSysFormat,        // serialize all TN_UDBase FLAGS fields (ObjVFlags and ObjUFlags)
  K_txtSaveVFlags,       // serialize all TN_UDBase ObjVFlags field
  K_txtSaveUFlags,       // serialize all TN_UDBase ObjUFlags field
  K_txtXMLMode,          // skip serialization of some system TN_UDBase fields while SDT format is used to serialized and deserialized data in XML format and UsedSPLTypes Info Unload and Check
  K_txtRACompact,        // not include in serialized data empty records arrays (TK_RArray)
  K_txtCompactArray,     // compact (multi column) string and number arrays format
  K_txtCompDblCoords,    // compact format for double coordinates (X,Y)
  K_txtCompIntCoords,    // compact format for integer coordinates (X,Y)
  K_txtSingleLineMode,   // ignore all NEW_LINE commands
  K_txtSkipCloseTagName, // skip close tags names (like in XML format)
  K_txtSkipMetaFields,   // all UDBase Meta fields (like in XML format)
  K_txtParseXMLTree,     // parse XML Tree to UDBase Tree of TK_UDStringList
  K_txtSkipTypesInfo,    // skip SPL types info serialization
  K_txtSkipUDMemData     // skip UDMem data for Compound File Structur unload
 );
//*** end of TK_TextModeFlags = Set of

//***** Global UDTree Control Flags
type TK_UDGControlFlags = (
  K_gcfSkipRefReplace,         // skip replacing UDRef Object to Direct reference
  K_gcfSysDateUse,             // set UDObj.ObjDateTime from K_SysDateTime istead of Real Date Time (used while loading to for )Equal to
  K_gcfRefIgnore,              // DirChild returns nil if real Child is TK_UDRef
  K_gcfSkipVTreeDeletion,      // Skip VTree Deletion (only clear child VNodes) while VTree Root UDNode Deletion
  K_gcfUseOnlyRefInd,          // while replacing UDRef Object to Direct reference skip searching Direct rerence by UDRef.RefPath Info if RefIndex is Undefined
  K_gcfRefInfoShow,            // while saving UDSubTree or building RefObjs save Replaced UDObj RefPath to RefObj.ObjAliase
  K_gcfSkipUnResoledRefInfo,   // while loading UDSubTree or replacing UDrefs to Direct Refs Skip show Brief and Detailed Info
  K_gcfSaveMarkerToRefObj,     // while saving UDSubTree or building RefObjs save Marker Info from Replaced UDObj to RefObj
  K_gcfArchSDTCopy,            // while saving UDSubTree (archive, section ...) to file save *.SDB and *.SDT copy (SDTFileName = SrcFileName.SDT)
  K_gcfTrySLSRSDTFileLoad,     // while loading archive load all sections text version
  K_gcfSkipFreeObjsDump,       // while saving UDSubTree to text or binary Skip  Dumping Info about Objects which have no Owners
  K_gcfSkipUDUnitSrcBinData,   // while saving UDSubtre to binary Skip TK_UDUnit Src Text saving
  K_gcfSaveUDUnitCompileData,  // while saving UDSubtre save TK_UDUnit Childs
  K_gcfSkipErrMessages,        // while loading UDSubTree skip all error messages
  K_gcfSaveSLSRMode,           // Save UDSubTree as Section mode - needed to Save Root Node Childs References as References
  K_gcfMaxFlagNumber,          // reserved value for K_UDGControl Flags Counters Array AutoSize
//*** Next Flags are synchronous with to TK_UDTreeLSFlagSet
  K_gcfSkipAllSLSR,
  K_gcfLoadAllSLSR,
  K_gcfJoinAllSLSR,
  K_gcfSetJoinToAllSLSR,
  K_gcfSkipJoinChangedSLSR,
  K_gcfDisjoinSLSR,
  K_gcfSkipReadOnlySLSR,
  K_gcfSaveReadOnlySLSR,
  K_gcfSkipEmptySLSR,
  K_gcfSaveEmptySLSR,
  K_gcfSaveNotChangedSLSR );
type TK_UDGControlFlagSet = Set of TK_UDGControlFlags;
//*** end of TK_UDGControlFlagSet = Set
//***** UDTree High Level Load/Save routines Flags
//*** This Flags are synchronous with to last flags of TK_UDGControlFlags
type TK_UDTreeLSFlagSet = Set of (
  K_lsfSkipAllSLSR,          // (while loading no section will be loaded, while saving no section will be saved)
  K_lsfLoadAllSLSR,          // (load all maualy loaded sections if K_lsfSkipAllSLSR not set)
  K_lsfJoinAllSLSR,          // (while loading archive acting as if all sections were joined, while saving acting if all sections have join flag)
  K_lsfSetJoinToAllSLSR,     // (while saving set join flag to all sections so they will be joined to archive)
  K_lsfSkipJoinChangedSLSR,  // (while saving skip adding join flag to all changed sections if K_lsfDisjoinSLSR not set)
  K_lsfDisjoinSLSR,          // (while saving clear join flag from all sections which have join flag and set them change flag so they will be saved in separate files)
  K_lsfSkipReadOnlySLSR,     // (while saving skip saving changed sections if they have read only flag without any dialog)
  K_lsfSaveReadOnlySLSR,     // (while saving save changed sections if they have read only flag without any dialog)
  K_lsfSkipEmptySLSR,        // (while saving skip saving changed sections if they have no childs without any dialog)
  K_lsfSaveEmptySLSR,        // (while saving save changed sections if they have no childs without any dialog)
  K_lsfSaveNotChangedSLSR ); // (while saving save sections in separate files even if thy were not changed)

//*** end of TK_UDSLSRFlagSet = Set

type TK_UDSysFolderType = (
  K_sftAddAll,           // add all childs
  K_sftSkipAll,          // skip all childs
  K_sftReplace,          // replace corresponding childs
  K_sftSkipOther,        // skip not corresponding childs
  K_sftReplaceObjName,   // replace corresponding childs
  K_sftSkipOtherObjName, // skip not corresponding childs
  K_sftAddUniqRefs       // clear doubled references after archives merging
);

//***** Separately Loaded SubTree Root Flags
type TK_SLSRModeFlags =  Set of (
  K_srfRoot,    // Separately Loaded SubTree Root Flag
  K_srfText,    // Separately Loaded SubTree Text Format Flag
  K_srfRead,    // Separately Loaded SubTree Read Only Flag
  K_srfManual,  // Separately Loaded SubTree Manualy Loaded Flag
  K_srfArchJoin // Separately Loaded SubTree Join to Archive Flag
   );

const
//****** use update parameters flag
//************ value of UDBase.ObjUFlags and  DE.DEVFlags
K_fuUseCurrent                   = $80000000;
K_fuUseGlobal                    = $40000000;
K_fuUseOR                        = $20000000;
K_fuUseMask                      = $5FFFFFFF;

//****** dir merge flags ******
//************ value of UDBase.ObjUFlags
K_fuDirFreeInsteadOfRemoving     = $10000; //** flag - make empty entries instead of childes removing
K_fuDirMergeEmptyEntriesUse      = $08000; // flag - use dest empty entries while childes adding
K_fuDirMergeEmptyEntriesSkip     = $04000; // flag - skip source empty entries while dir merging
K_fuDirMergeUniqDEName           = $02000; // flag - make unique dir entry names
K_fuDirMergeUniqObjNameNone      = $01000; // flag - make unique obj entry names
K_fuDirUseCorresponding          = $00100; // flag - update corresponding entries
//*** if not K_fuDirUseCorresponding
K_fuDirMergeClearOld             = $00200; // flag - clear dir before merging
//*** if K_fuDirUseCorresponding
K_fuDirMergeNotCorrespondingNone = $00200; // flag - add not corresponding source entries
K_fuDirMergeCorrespondingNone    = $00400; // flag - not update corresponding source entries
K_fuDirCorrespondingUFunc        = $00800; // flag - use onCorresponding routine


//****** search corresponding flags ******
K_fuDirCorrespondingSearchMask   = $000FF;
K_fuDirCorrespondingDEType       = $00001;
K_fuDirCorrespondingDECode       = $00002;
K_fuDirCorrespondingDEChild      = $00004;
K_fuDirCorrespondingDEName       = $00008;
K_fuDirCorrespondingDEProtected  = $00010;
//reserved                       = $00020;
K_fuDirCorrespondingObjName      = $00040;
K_fuDirCorrespondingObjType      = $00080;


//****** object properties  ******
//************ value of ObjFlags
K_fpObjProtected      = $00000001; // flag - object couldn't be deleted manualy
//K_fpObjRuntime      = $00000010; // flag - runtime root node
K_fpObjSkipChildsSave = $00000010; // flag - Skip Obj Childs from Binary and Text SubTree serialization

// Separately Loaded SubTree Root Flags
K_fpObjSLSRFlag     = $00000020; // Separately Loaded SubTree Root Flag
K_fpObjSLSRFText    = $00000040; // Separately Loaded SubTree Format: =0 - Binary, =1 Text
K_fpObjSLSRRead     = $00000080; // Separately Loaded SubTree Read Only Flag
K_fpObjSLSRMLoad    = $00000100; // Separately Loaded SubTree Manualy Loaded Flag
K_fpObjSLSRJoin     = $00000200; // Separately Loaded SubTree will be Joined to Archive while saving Flag
K_fpObjSLSRFMask    = $000003E0; // Separately Loaded SubTree Flags Mask

// User Marks Flags
K_fpObjTVDisabled     = $00001000; // Tree View Disabled flag
K_fpObjTVChecked      = $00002000; // Tree View Checked flag
K_fpObjTVAutoCheck    = $00004000; // Tree View AutoCheck flag
K_fpObjTVSpecMark1    = $00008000; // Tree View Special Mark 1
//K_fpObjUserMark3      = $00008000; // User Bit Mark 4
K_fpObjUserMarkMask   = $0000F000; // User Bit Marks Mask

// Archive System Folders Flags
K_fpObjSFTypePos    = 20;
//K_fpObjSFAddAll     = Ord(K_sftAddAll)    shl K_fpObjSFTypePos; // flag - ArchSysFolder type - add all childs
//K_fpObjSFSkip       = Ord(K_sftSkipAll)   shl K_fpObjSFTypePos; // flag - ArchSysFolder type - skip all childs
//K_fpObjSFReplace    = Ord(K_sftReplace)   shl K_fpObjSFTypePos; // flag - ArchSysFolder type - replace corresponding childs
//K_fpObjSFSkipOther  = Ord(K_sftSkipOther) shl K_fpObjSFTypePos; // flag - ArchSysFolder type - skip not corresponding childs
//K_fpObjSFReplaceON  = Ord(K_sftReplaceObjName)   shl K_fpObjSFTypePos; // flag - ArchSysFolder type - replace corresponding childs
//K_fpObjSFSkipOtherON= Ord(K_sftSkipOtherObjName) shl K_fpObjSFTypePos; // flag - ArchSysFolder type - skip not corresponding childs
K_fpObjSFAddUniqRefs= Ord(K_sftAddUniqRefs)  shl K_fpObjSFTypePos; // flag - ArchSysFolder type - clear doubled references after merging
K_fpObjSFTypeMask   = $07F00000; // flag - archive system folder type mask
K_fpObjSFolder      = $00800000; // flag - archive system folder flag

// Path Building Flags
K_fpObjPathNoExt    = $02000000; // flag - not use DEName or DECode in Path
K_fpObjPathNoName   = $04000000; // flag - not use ObjName in Path
K_fpObjPathUCheck   = $08000000; // flag - use Unique Path Check

// Miscellaneous System Flags
K_fpObjOwnerLinkNon = $80000000; // flag - object couldn't catch free nodes as owner

//****** tree node entries update flags ******
//************ value of DE.DEUFlags
K_fuDEDataExchange                  = $10000; // DirEntry data exchange Flag
//*** if K_fuDEDataExchange - only end data chage mode
K_fuDEDTCollisionUserFunc           = $00020; // use user func to solve data exchange collision
//*** if not K_fuDEDTCollisionUserFunc
K_fuDEDataTypeChange                = $00010; // data type change permition
//*** if not K_fuDEDataTypeChange
K_fuDEDTCollisionMessageNone        = $00002; // not show type collision message window
K_fuDEDTCollisionStop               = $00001; // stop if data collision

//*** if not K_fuDEDataExchange - change UDBase Net Structure
K_fuDEChangeOwner                   = $02000; // Change Owner while Data Replace
K_fuDESubTreeLinksGlobalReplace     = $01000; // global replace of SubTree links
K_fuDESubTreeLinksGlobalReplaceNone = $00800; // stop child links global replacing

K_fuDENodeCloneNone                 = $00400; // flag - not clone child
//*** if K_fuDENodeCloneNone
K_fuDENodeUpdateDataMask            = $00070;
K_fuDENodeUpdateMetaNone            = $00010; // flag - not replace dir entry meta data
K_fuDENodeUpdateFieldsNone          = $00020; // flag - not replace obj fields
K_fuDENodeUpdateDirNone             = $00040; // flag - not merge objs dirs
K_fuDENodeUpdateDataNone            = $00070; //
//*** if not K_fuDENodeCloneNone - update cloned node flags
// K_fuDENodeUpdateMetaNone            = $00010; // flag - use old obj meta for new obj
// K_fuDENodeUpdateFieldsNone          = $00020; // flag - not replace obj fields
// K_fuDENodeUpdateDirNone             = $00040; // flag - not merge objs dirs
K_fuDENodeMetaOld                   = $00080; // flag - use old obj meta for new obj
K_fuDENodeFieldsOld                 = $00100; // flag - use old obj fields for new obj
K_fuDENodeDirOld                    = $00200; // flag - use old obj dir for new obj
//*** if full cloning flags
K_fuDENodeFullCloneMask             = $000F0;
K_fuDENodeFullClone                 = $00000; // field

//****** dir entry update flags ******
K_fuDECRefGlobalReplace             = $00008; // use this link replacement to hall tree
K_fuDEReplaceMask                   = $00007; // field mask
K_fuDEMetaReplaceNone               = $00004; // flag
K_fuDEDataReplaceMask               = $00003; // field mask
K_fuDEChildUpdate                   = $00000; // Replace link field value
K_fuDEDataReplace                   = $00001; // Replace link field value
K_fuDEDataClear                     = $00002; // Replace link field value
K_fuDEDataReplaceNone               = $00003; // Replace link field value
K_fuDEReplaceNone                   = K_fuDEDataReplaceNone + K_fuDEMetaReplaceNone;


//****** dir entry properties  ******
//************ value of DE.DEFlags
K_fpDEProtected      = $00000001; // flag - dir entry is protected - couldn't be removed
//K_fpDEObjOwner       = $00000002; // flag - dir entry is child owner -
//                                  //  could be removed only with child (RefCounter=1)
K_fpDEObjProtected   = $00000004; // flag - child is protected - child and
                                  //        dir entry couldn't be removed
K_fpDEParentAncestor = $00000008; // flag - child is ancestor of the parent

//****** text tags and attributes
K_tbEmptyTag   = 'empty';  // empty dir entry text tag
K_tbRootTag    = 'sdml';   // Root File tag
K_tbDEName     = 'DEName'; // dir entry name attribute
K_tbDECode     = 'DECode'; // dir entry code attribute
K_tbDEFlags    = 'DEF';    // dir entry flags attribute
K_tbDEValue    = 'Value';  // dir entry value attribute
K_tbDEUFlags   = 'DEUF';   // dir entry update flags attribute
K_tbDEVFlags   = 'DEVF';   // dir entry visual flags attribute
K_tbObjName    = 'Name';   // object name attribute
K_tbObjAliase  = 'Aliase'; // object aliase attribute
K_tbObjInfo    = 'Info';   // object Info attribute
K_tbObjFlags   = 'Flags';  // object flags attribute
K_tbObjUDFlags  = 'UDFlags'; // Object directory update flags attribute
K_tbObjUEFlags  = 'UEFlags'; // Object directory entries update flags attribute
K_tbObjVFlags  = 'VFlags'; // Obj visual flags attribute
K_tbObjDate    = 'Date';   // Obj date  attribute
K_tbObjID      = 'ID';     // Obj ID  attribute
K_tbObjRef     = 'Ref';    // Obj reference  attribute
K_tbObjRefPath = 'Ref';    // Obj reference path attribute
K_tbObjRefChildPath = 'RPath'; // Child Obj reference path attribute
K_tbObjRefInd  = 'RefInd'; // Obj reference index attribute
K_tbObjImgInd  = 'ImgInd'; // Obj TreeView icon index attribute
K_tbObjTextFMT = 'SysFmt'; // Obj text format attribute
K_tbArrLength  = 'ArrLength'; // Array Length attribute
K_tbArrAccur   = 'ArrAccur'; // Double Array Accuracy attribute

K_udpPathDelim = '\';
K_udpDECodeDelim = '#';
K_udpDEIndexDelim = '%';
K_udpDENameDelim = '|';
K_udpDataArrayDelim = '[';
K_udpObjTypeNameDelim = '&';
K_udpCursorDelim = ':';
K_udpFieldDelim = '!';
K_udpAttrFieldDelim = '.!';
K_udpStepUp = '..';
K_udpDelims1 = K_udpPathDelim + K_udpCursorDelim;
K_udpDelims2 = K_udpPathDelim + K_udpCursorDelim + K_udpFieldDelim;
K_udpRANamePref = '#'; // TK_RAListItem Name Prefix

K_udpNoCursor = '*';
K_udpAbsPathCursorName = '@:';
K_udpLocalPathCursorName = 'L@:';

K_udpArchivesRootName = 'Archives';
K_udpSPLRootName = 'SPL';
K_udpFilesRootName = 'Files';

var
  K_TextModeFlags : TK_TextModeFlags = [K_txtSkipDblNewLine,K_txtRACompact,
                       K_txtSaveVFlags, K_txtSaveUFlags, K_txtCompactArray,
                       K_txtSkipCloseTagName];

implementation

end.
