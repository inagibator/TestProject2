unit K_ASPLInit;

interface

implementation

uses inifiles, Classes,
  N_ClassRef, K_parse, K_UDConst, K_Script1, K_Script2, K_SParse1, K_FSDeb;

var i : Integer;

Initialization
// K_FSDeb
 K_DebugGC := nil;

// K_Script1
  Randomize;

  K_CurUDRefRoot := nil;

  K_ScriptLDDataTokenizer := TK_Tokenizer.Create( '', ' '+#$A#$D#9+'),',
      '""'+''''''+'()' );
  K_ScriptLDDataTokenizer.setNestedBracketsInd( 5 );

  K_PascalHandles := THashedStringList.Create;

//*********************************
//*** N_ClassRef Initialization ***
//*********************************

  N_ClassRefArray[K_UDFieldsDescrCI] := TK_UDFieldsDescr;
  N_ClassTagArray[K_UDFieldsDescrCI] := 'FieldsDescription';

  N_ClassRefArray[K_UDProgramItemCI] := TK_UDProgramItem;
  N_ClassTagArray[K_UDProgramItemCI] := 'ProgramItem';

  N_ClassRefArray[K_UDRArrayCI]      := TK_UDRArray;
  N_ClassTagArray[K_UDRArrayCI]      := 'Records';

  N_ClassRefArray[K_UDRAListCI]      := TK_UDRAList;
  N_ClassTagArray[K_UDRAListCI]      := 'RAList';

  N_ClassRefArray[K_UDUnitDataCI]    := TK_UDUnitData;
  N_ClassTagArray[K_UDUnitDataCI]    := 'UnitData';

  N_ClassRefArray[K_UDStringListCI]  := TK_UDStringList;
  N_ClassTagArray[K_UDStringListCI]  := 'Strings';

  N_ClassRefArray[K_UDUnitCI]        := TK_UDUnit;
  N_ClassTagArray[K_UDUnitCI]        := 'spl';

  N_ClassRefArray[K_UDRPTabCI]       := TK_UDRPTab;
  N_ClassTagArray[K_UDRPTabCI]       := 'UDRPTab';

//**********************************
//*** K_ExprNFunc Initialization ***
//**********************************

// K_Script1
//**************** SPL BuildIn Funcs 0 - 139, 160 - 170 **************************
//**************** Free Inds 87-89, 127-139,

//SPL BuildIn Funcs ********  0 - 99
  K_ExprNFuncNames[K_ExprNCLSFuncCI] := 'CLS'; //clear stack
  K_ExprNFuncRefs [K_ExprNCLSFuncCI] := K_ExprNClearStack;

  K_ExprNFuncNames[K_ExprNSetFuncCI] := 'Set'; //set value to expression left side
  K_ExprNFuncRefs [K_ExprNSetFuncCI] := K_ExprNSetResultValue;

  K_ExprNFuncNames[K_ExprNValFuncCI] := K_sccVarConvToValue;
  K_ExprNFuncRefs [K_ExprNValFuncCI] := K_ExprNChangePointerToData;

  K_ExprNFuncNames[K_ExprNSetLengthFuncCI] := 'SetLength';
  K_ExprNFuncRefs [K_ExprNSetLengthFuncCI] := K_ExprNSetLength;

  K_ExprNFuncNames[K_ExprNSumIntsFuncCI] := K_SPLTypeNames[Ord(nptInt)]+K_expAddOp;
  K_ExprNFuncRefs [K_ExprNSumIntsFuncCI] := K_ExprNSumInts;

  K_ExprNFuncNames[K_ExprNCallRoutineFuncCI] := '_call';
  K_ExprNFuncRefs [K_ExprNCallRoutineFuncCI] := K_ExprNCallRoutine;

  K_ExprNFuncNames[K_ExprNArrayElementFuncCI] := '_ElemPointer';
  K_ExprNFuncRefs [K_ExprNArrayElementFuncCI] := K_ExprNArrayElement;

  K_ExprNFuncNames[K_ExprNCreateInstanceFuncCI] := '_CreateInstance';
  K_ExprNFuncRefs [K_ExprNCreateInstanceFuncCI] := K_ExprNCreateInstance;

  K_ExprNFuncNames[K_ExprNCallMethodFuncCI] := '_CallMethod';
  K_ExprNFuncRefs [K_ExprNCallMethodFuncCI] := K_ExprNCallMethod;

  K_ExprNFuncNames[K_ExprNGetInstanceFuncCI] := '_PInstance';
  K_ExprNFuncRefs [K_ExprNGetInstanceFuncCI] := K_ExprNGetInstance;

  K_ExprNFuncNames[K_ExprNSubArrayFuncCI] := 'SubArray';
  K_ExprNFuncRefs [K_ExprNSubArrayFuncCI] := K_ExprNSubArray;

  K_ExprNFuncNames[K_ExprNUDCreateFuncCI] := 'UDCreate';
  K_ExprNFuncRefs [K_ExprNUDCreateFuncCI] := K_ExprNUDCreate;

  K_ExprNFuncNames[K_ExprNSetElemFuncCI] := 'SetElements';
  K_ExprNFuncRefs [K_ExprNSetElemFuncCI] := K_ExprNSetElements;

  K_ExprNFuncNames[K_ExprNMoveFuncCI] := 'Move';
  K_ExprNFuncRefs [K_ExprNMoveFuncCI] := K_ExprNMove;

{}

  K_ExprNFuncNames[14] := 'GetVarTypeInfo';
  K_ExprNFuncRefs [14] := K_ExprNGetVarTypeInfo;
{}
  K_ExprNFuncNames[15] := K_SPLTypeNames[Ord(nptDouble)]+K_expAddOp;
  K_ExprNFuncRefs [15] := K_ExprNSumDoubles;

  K_ExprNFuncNames[16] := K_SPLTypeNames[Ord(nptFloat)]+K_expAddOp;
  K_ExprNFuncRefs [16] := K_ExprNSumFLoats;

  K_ExprNFuncNames[17] := K_SPLTypeNames[Ord(nptByte)]+K_expAddOp;
  K_ExprNFuncRefs [17] := K_ExprNSumBytes;

  K_ExprNFuncNames[18] := K_SPLTypeNames[Ord(nptString)]+K_expAddOp;
  K_ExprNFuncRefs [18] := K_ExprNSumStrings;

  K_ExprNFuncNames[19] := K_SPLTypeNames[Ord(nptInt)]+K_expSubOp;
  K_ExprNFuncRefs [19] := K_ExprNSubInts;

  K_ExprNFuncNames[20] := K_SPLTypeNames[Ord(nptDouble)]+K_expSubOp;
  K_ExprNFuncRefs [20] := K_ExprNSubDoubles;

  K_ExprNFuncNames[21] := K_SPLTypeNames[Ord(nptFloat)]+K_expSubOp;
  K_ExprNFuncRefs [21] := K_ExprNSubFLoats;

  K_ExprNFuncNames[22] := K_SPLTypeNames[Ord(nptInt)]+K_expMultOp;
  K_ExprNFuncRefs [22] := K_ExprNMultInts;

  K_ExprNFuncNames[23] := K_SPLTypeNames[Ord(nptDouble)]+K_expMultOp;
  K_ExprNFuncRefs [23] := K_ExprNMultDoubles;

  K_ExprNFuncNames[24] := K_SPLTypeNames[Ord(nptFloat)]+K_expMultOp;
  K_ExprNFuncRefs [24] := K_ExprNMultFloats;

  K_ExprNFuncNames[25] := K_SPLTypeNames[Ord(nptDouble)]+K_expDivOp;
  K_ExprNFuncRefs [25] := K_ExprNDivDoubles;

  K_ExprNFuncNames[26] := K_SPLTypeNames[Ord(nptFloat)]+K_expDivOp;
  K_ExprNFuncRefs [26] := K_ExprNDivFloats;

  K_ExprNFuncNames[27] := K_SPLTypeNames[Ord(nptInt)]+'To'+K_SPLTypeNames[Ord(nptDouble)];
  K_ExprNFuncRefs [27] := K_ExprNIntToDouble;

  K_ExprNFuncNames[28] := K_SPLTypeNames[Ord(nptDouble)]+'To'+K_SPLTypeNames[Ord(nptInt)];
  K_ExprNFuncRefs [28] := K_ExprNDoubleToInt;

  K_ExprNFuncNames[29] := K_SPLTypeNames[Ord(nptInt)]+'To'+K_SPLTypeNames[Ord(nptByte)];
  K_ExprNFuncRefs [29] := K_ExprNIntToByte;

  K_ExprNFuncNames[30] := K_SPLTypeNames[Ord(nptByte)]+'To'+K_SPLTypeNames[Ord(nptInt)];
  K_ExprNFuncRefs [30] := K_ExprNByteToInt;

  K_ExprNFuncNames[31] := K_SPLTypeNames[Ord(nptFloat)]+'To'+K_SPLTypeNames[Ord(nptDouble)];
  K_ExprNFuncRefs [31] := K_ExprNFloatToDouble;

  K_ExprNFuncNames[32] := K_SPLTypeNames[Ord(nptDouble)]+'To'+K_SPLTypeNames[Ord(nptFloat)];
  K_ExprNFuncRefs [32] := K_ExprNDoubleToFloat;

  K_ExprNFuncNames[33] := K_SPLTypeNames[Ord(nptInt)]+'To'+K_SPLTypeNames[Ord(nptString)];
  K_ExprNFuncRefs [33] := K_ExprNIntToString;

  K_ExprNFuncNames[34] := K_SPLTypeNames[Ord(nptDouble)]+'To'+K_SPLTypeNames[Ord(nptString)];
  K_ExprNFuncRefs [34] := K_ExprNDoubleToString;

  K_ExprNFuncNames[35] := K_SPLTypeNames[Ord(nptFloat)]+'To'+K_SPLTypeNames[Ord(nptString)];
  K_ExprNFuncRefs [35] := K_ExprNFloatToString;

  K_ExprNFuncNames[36] := K_SPLTypeNames[Ord(nptUDRef)]+'To'+K_SPLTypeNames[Ord(nptInt)];
  K_ExprNFuncRefs [36] := K_ExprNUDRefToInt;

  K_ExprNFuncNames[37] := K_SPLTypeNames[Ord(nptInt)]+'To'+K_SPLTypeNames[Ord(nptUDRef)];
  K_ExprNFuncRefs [37] := K_ExprNIntToUDRef;

  K_ExprNFuncNames[38] := K_SPLTypeNames[Ord(nptString)]+'To'+K_SPLTypeNames[Ord(nptUDRef)];
  K_ExprNFuncRefs [38] := K_ExprNStringToUDRef;

  K_ExprNFuncNames[39] := K_SPLTypeNames[Ord(nptInt)]+'To'+K_SPLTypeNames[Ord(nptInt2)];
  K_ExprNFuncRefs [39] := K_ExprNIntToShort;

  K_ExprNFuncNames[40] := K_SPLTypeNames[Ord(nptInt2)]+'To'+K_SPLTypeNames[Ord(nptInt)];
  K_ExprNFuncRefs [40] := K_ExprNShortToInt;

  K_ExprNFuncNames[41] := 'UDP';
  K_ExprNFuncRefs [41] := K_ExprNStringToUDRef;

  K_ExprNFuncNames[42] := 'Beep';
  K_ExprNFuncRefs [42] := K_ExprNBeep;

  K_ExprNFuncNames[43] := 'Random';
  K_ExprNFuncRefs [43] := K_ExprNRandom;

  K_ExprNFuncNames[44] := 'DelElements';
  K_ExprNFuncRefs [44] := K_ExprNDelElements;

  K_ExprNFuncNames[45] := 'InsElements';
  K_ExprNFuncRefs [45] := K_ExprNInsElements;

  K_ExprNFuncNames[46] := 'FillElements';
  K_ExprNFuncRefs [46] := K_ExprNFillElements;

  K_ExprNFuncNames[47] := 'SubString';
  K_ExprNFuncRefs [47] := K_ExprNSubString;

  K_ExprNFuncNames[48] := 'ShowDump';
  K_ExprNFuncRefs [48] := K_ExprNShowDump;

  K_ExprNFuncNames[49] := 'format';
  K_ExprNFuncRefs [49]  := K_ExprNFormat;

  K_ExprNFuncNames[50] := 'UDRP';
  K_ExprNFuncRefs [50]  := K_ExprNUDRDataRef;

  K_ExprNFuncNames[51] := 'UDChildByInd';
  K_ExprNFuncRefs [51]  := K_ExprNUDChildByInd;

  K_ExprNFuncNames[52] := 'UDDirHigh';
  K_ExprNFuncRefs [52]  := K_ExprNUDDirHigh;

  K_ExprNFuncNames[53] := 'UDDirLength';
  K_ExprNFuncRefs [53]  := K_ExprNUDDirLength;

  K_ExprNFuncNames[54] := 'UDAddToParent';
  K_ExprNFuncRefs [54]  := K_ExprNUDAddToParent;

  K_ExprNFuncNames[55] := 'UDAddToOwner';
  K_ExprNFuncRefs [55]  := K_ExprNUDAddToOwner;

  K_ExprNFuncNames[56] := '_UDComponentObject';
  K_ExprNFuncRefs [56]  := K_ExprNUDComponentObject;

  K_ExprNFuncNames[57] := 'UDSetName';
  K_ExprNFuncRefs [57]  := K_ExprNSetUDRefName;

  K_ExprNFuncNames[58] := 'UDPutToParent';
  K_ExprNFuncRefs [58] := K_ExprNUDPutToParent;

  K_ExprNFuncNames[59] := 'CopyData';
  K_ExprNFuncRefs [59] := K_ExprNCopyData;

  K_ExprNFuncNames[60] := 'PutArrayToUD';
  K_ExprNFuncRefs [60] := K_ExprNPutArrayToUD;

  K_ExprNFuncNames[61] := 'GetArrayFromUD';
  K_ExprNFuncRefs [61] := K_ExprNGetArrayFromUD;

  K_ExprNFuncNames[62] := 'SetUDRef';
  K_ExprNFuncRefs [62] := K_ExprNSetUDRef;

  K_ExprNFuncNames[63] := 'ToString';
  K_ExprNFuncRefs [63]  := K_ExprNToString;

  K_ExprNFuncNames[64] := 'ShowEditData';
  K_ExprNFuncRefs [64]  := K_ExprNShowEditData;

  K_ExprNFuncNames[65] := 'ShowEditDataForm';
  K_ExprNFuncRefs [65]  := K_ExprNShowEditDataForm;

  K_ExprNFuncNames[66] := 'ShowMessage';
  K_ExprNFuncRefs [66] := K_ExprNShowMessage;

  K_ExprNFuncNames[67] := 'GetPascalHandle';
  K_ExprNFuncRefs [67] := K_ExprNGetPascalHandle;

  K_ExprNFuncNames[68] := 'PascalNotifyFunc';
  K_ExprNFuncRefs [68]  := K_ExprNPascalNotifyFunc;

  K_ExprNFuncNames[69] := K_SPLTypeNames[Ord(nptTDate)]+K_expAddOp;
  K_ExprNFuncRefs [69] := K_ExprNSumDoubles;

  K_ExprNFuncNames[70] := K_SPLTypeNames[Ord(nptTDate)]+K_expSubOp;
  K_ExprNFuncRefs [70] := K_ExprNSubDoubles;

  K_ExprNFuncNames[71] := K_SPLTypeNames[Ord(nptString)]+'To'+K_SPLTypeNames[Ord(nptTDate)];
  K_ExprNFuncRefs [71] := K_ExprNStringToTDate;

  K_ExprNFuncNames[72] := K_SPLTypeNames[Ord(nptTDate)]+'To'+K_SPLTypeNames[Ord(nptString)];
  K_ExprNFuncRefs [72] := K_ExprNTDateToString;

  K_ExprNFuncNames[73] := 'time';
  K_ExprNFuncRefs [73] := K_ExprNGetTime;

  K_ExprNFuncNames[74] := 'date';
  K_ExprNFuncRefs [74] := K_ExprNGetDate;

  K_ExprNFuncNames[75] := 'SLength';
  K_ExprNFuncRefs [75] := K_ExprNSLength;

  K_ExprNFuncNames[76] := 'ALength';
  K_ExprNFuncRefs [76] := K_ExprNALength;

  K_ExprNFuncNames[77] := 'SetTimeout';
  K_ExprNFuncRefs [77] := K_ExprNSetTimeout;

  K_ExprNFuncNames[78] := 'ClearTimeout';
  K_ExprNFuncRefs [78] := K_ExprNClearTimeout;

  K_ExprNFuncNames[79] := 'Bit';
  K_ExprNFuncRefs [79] := K_ExprNBit;

  K_ExprNFuncNames[80]  := K_SPLTypeNames[Ord(nptInt)]+K_expAndOp;
  K_ExprNFuncRefs [80]  := K_ExprNAndInts;

  K_ExprNFuncNames[81]  := K_SPLTypeNames[Ord(nptInt)]+K_expOrOp;
  K_ExprNFuncRefs [81]  := K_ExprNOrInts;

  K_ExprNFuncNames[82]  := K_SPLTypeNames[Ord(nptInt)]+K_expXorOp;
  K_ExprNFuncRefs [82]  := K_ExprNXorInts;

  K_ExprNFuncNames[83]  := K_expNotOp+K_SPLTypeNames[Ord(nptInt)];
  K_ExprNFuncRefs [83]  := K_ExprNNotInt;

{
  K_ExprNFuncNames[84]  := '$$$$$$r41';
  K_ExprNFuncRefs [84]  := K_ExprNMinusFLoat;

  K_ExprNFuncNames[85]  := '$$$$$$r42';
  K_ExprNFuncRefs [85]  := K_ExprNMinusFLoat;

  K_ExprNFuncNames[86]  := '$$$$$$r43';
  K_ExprNFuncRefs [86]  := K_ExprNMinusFLoat;
}
  K_ExprNFuncNames[87]  := K_SPLTypeNames[Ord(nptString)]+K_expEQOp;
  K_ExprNFuncRefs [87]  := K_ExprNEQStrings;

  K_ExprNFuncNames[88]  := K_SPLTypeNames[Ord(nptInt)]+K_expEQOp;
  K_ExprNFuncRefs [88]  := K_ExprNEQInts;

  K_ExprNFuncNames[89]  := K_SPLTypeNames[Ord(nptDouble)]+K_expEQOp;
  K_ExprNFuncRefs [89]  := K_ExprNEQDoubles;

  K_ExprNFuncNames[90]  := K_SPLTypeNames[Ord(nptFloat)]+K_expEQOp;
  K_ExprNFuncRefs [90]  := K_ExprNEQFloats;

  K_ExprNFuncNames[91]  := K_SPLTypeNames[Ord(nptInt)]+K_expLTOp;
  K_ExprNFuncRefs [91]  := K_ExprNLTInts;

  K_ExprNFuncNames[92]  := K_SPLTypeNames[Ord(nptDouble)]+K_expLTOp;
  K_ExprNFuncRefs [92]  := K_ExprNLTDoubles;

  K_ExprNFuncNames[93]  := K_SPLTypeNames[Ord(nptFloat)]+K_expLTOp;
  K_ExprNFuncRefs [93]  := K_ExprNLTFloats;

  K_ExprNFuncNames[94]  := K_SPLTypeNames[Ord(nptInt)]+K_expGTOp;
  K_ExprNFuncRefs [94]  := K_ExprNGTInts;

  K_ExprNFuncNames[95]  := K_SPLTypeNames[Ord(nptDouble)]+K_expGTOp;
  K_ExprNFuncRefs [95]  := K_ExprNGTDoubles;

  K_ExprNFuncNames[96]  := K_SPLTypeNames[Ord(nptFloat)]+K_expGTOp;
  K_ExprNFuncRefs [96]  := K_ExprNGTFloats;

  K_ExprNFuncNames[97]  := K_expSubOp+K_SPLTypeNames[Ord(nptInt)];
  K_ExprNFuncRefs [97]  := K_ExprNMinusInt;

  K_ExprNFuncNames[98]  := K_expSubOp+K_SPLTypeNames[Ord(nptDouble)];
  K_ExprNFuncRefs [98]  := K_ExprNMinusDouble;

  K_ExprNFuncNames[99]  := K_expSubOp+K_SPLTypeNames[Ord(nptFLoat)];
  K_ExprNFuncRefs [99]  := K_ExprNMinusFLoat;

//SPL BuildIn Funcs ********  100 - 149
  K_ExprNFuncNames[100] := 'TreeViewUpdate';
  K_ExprNFuncRefs [100] := K_ExprNTreeViewUpdate;

  K_ExprNFuncNames[101] := 'ShowFDump';
  K_ExprNFuncRefs [101] := K_ExprNShowFDump;

  K_ExprNFuncNames[102] := 'ARowLength';
  K_ExprNFuncRefs [102] := K_ExprNARowLength;

  K_ExprNFuncNames[103] := 'SetRowLength';
  K_ExprNFuncRefs [103] := K_ExprNSetRowLength;

  K_ExprNFuncNames[104] := 'NewArrayByTypeCode';
  K_ExprNFuncRefs [104] := K_ExprNNewArrayByTypeCode;

  K_ExprNFuncNames[105] := 'NewArrayByTypeName';
  K_ExprNFuncRefs [105] := K_ExprNNewArrayByTypeName;

  K_ExprNFuncNames[106] := 'AElemTypeCode';
  K_ExprNFuncRefs [106] := K_ExprNAElemTypeCode;

  K_ExprNFuncNames[107] := 'AElemTypeName';
  K_ExprNFuncRefs [107] := K_ExprNAElemTypeName;

  K_ExprNFuncNames[108] := 'PField';
  K_ExprNFuncRefs [108] := K_ExprNPField;

  K_ExprNFuncNames[109] := 'PutVArray';
  K_ExprNFuncRefs [109] := K_ExprNPutVArray;

  K_ExprNFuncNames[110] := 'GetVArray';
  K_ExprNFuncRefs [110] := K_ExprNGetVArray;

  K_ExprNFuncNames[111] := 'StrToNumber';
  K_ExprNFuncRefs [111] := K_ExprNStrToNumber;

  K_ExprNFuncNames[112] := 'ATypeName';
  K_ExprNFuncRefs [112] := K_ExprNATypeName;

  K_ExprNFuncNames[113] := 'TranspMatrix';
  K_ExprNFuncRefs [113] := K_ExprNTranspMatrix;

  K_ExprNFuncNames[114] := 'GetSubArray';
  K_ExprNFuncRefs [114] := K_ExprNGetSubArray;

  K_ExprNFuncNames[115] := 'CopySubMatrix';
  K_ExprNFuncRefs [115] := K_ExprNCopySubMatrix;

  K_ExprNFuncNames[116] := 'ARowsRangeCount';
  K_ExprNFuncRefs [116] := K_ExprNARowsRangeCount;

  K_ExprNFuncNames[117] := 'AColsRangeCount';
  K_ExprNFuncRefs [117] := K_ExprNAColsRangeCount;

  K_ExprNFuncNames[118] := 'StrMatrixSearch';
  K_ExprNFuncRefs [118] := K_ExprNStrMatrixSearch;

  K_ExprNFuncNames[119] := 'Ceil';
  K_ExprNFuncRefs [119] := K_ExprNCeil;

  K_ExprNFuncNames[120] := 'Floor';
  K_ExprNFuncRefs [120] := K_ExprNFloor;

  K_ExprNFuncNames[121] := 'Round';
  K_ExprNFuncRefs [121] := K_ExprNRound;

  K_ExprNFuncNames[122] := 'Sqrt';
  K_ExprNFuncRefs [122] := K_ExprNSqrt;

  K_ExprNFuncNames[123] := 'StrToIBool';
  K_ExprNFuncRefs [123] := K_ExprNStrToIBool;

  K_ExprNFuncNames[124] := 'UpperCase';
  K_ExprNFuncRefs [124] := K_ExprNUpperCase;

  K_ExprNFuncNames[125] := 'LowerCase';
  K_ExprNFuncRefs [125] := K_ExprNLowerCase;

  K_ExprNFuncNames[126] := 'CompareData';
  K_ExprNFuncRefs [126] := K_ExprNCompareData;

  K_ExprNFuncNames[127] := 'Abs';
  K_ExprNFuncRefs [127] := K_ExprNAbs;

//SPL BuildIn Funcs ********  160 - 170

  K_ExprNFuncNames[160] := 'ExecComponent';
  K_ExprNFuncRefs [160] := K_ExprNExecComponent;

  K_ExprNFuncNames[161] := 'InsComponent';
  K_ExprNFuncRefs [161] := K_ExprNInsComponent;

  K_ExprNFuncNames[162] := 'UDCursorInit';
  K_ExprNFuncRefs [162] := K_ExprNUDCursorInit;

  K_ExprNFuncNames[163] := 'BuildDPIndexes';
  K_ExprNFuncRefs [163] := K_ExprNBuildDPIndexes;

  K_ExprNFuncNames[164] := 'UDFP';
  K_ExprNFuncRefs [164] := K_ExprNUDRFieldRef;

  K_ExprNFuncNames[165] := K_SPLTypeNames[Ord(nptString)]+'To'+K_SPLTypeNames[Ord(nptType)];
  K_ExprNFuncRefs [165] := K_ExprNStringToType;

  K_ExprNFuncNames[166] := K_SPLTypeNames[Ord(nptType)]+'To'+K_SPLTypeNames[Ord(nptString)];
  K_ExprNFuncRefs [166] := K_ExprNTypeToString;

  K_ExprNFuncNames[167] := 'PType0';
  K_ExprNFuncRefs [167] := K_ExprNTypeOfPointer0;

  K_ExprNFuncNames[168] := 'TPtr0';
  K_ExprNFuncRefs [168] := K_ExprNTypedPointer0;

  K_ExprNFuncNames[169] := 'PType';
  K_ExprNFuncRefs [169] := K_ExprNTypeOfPointer;

  K_ExprNFuncNames[170] := 'TPtr';
  K_ExprNFuncRefs [170] := K_ExprNTypedPointer;


// K_SParse1
//*** Base Types List
  K_SHBaseTypesList := THashedStringList.Create;
  K_SHBaseTypesList.CaseSensitive := false;

  for i := 0 to Ord(nptNoData) do
    K_SHBaseTypesList.Add(K_SPLTypeNames[i]);

//*** Compiled Types List
  K_TypeDescrsList := THashedStringList.Create;
  K_TypeDescrsList.CaseSensitive := false;

  K_UnitsRoot := K_udpAbsPathCursorName + K_udpPathDelim + K_udpSPLRootName;

  K_ST := TK_Tokenizer.Create( '', K_sccDelimsSet,
        K_sccTokenBrackets );
  K_ST.setNonRecurringDelimsInd( 4 );
  K_ST.setNestedBracketsInd( 5 );

  K_SPT := TK_Tokenizer.Create( '', K_sccParDelimsSet,
        K_sccParDelimsBrackets );
  K_SPT.setNonRecurringDelimsInd( 5 );
  K_SPT.setNestedBracketsInd( 5 );

  //*** Expression Parser Ini
  SetLength( K_OpParseStack, 5 );

  //*** Wrk Data Lists
  K_SHEnumMembersList := nil;
  K_SHDataTypesList := nil;
  K_LGlobalData := nil;

  K_SHUsedRLData := THashedStringList.Create;
  K_SHUsedRLData.CaseSensitive := false;

  K_SHRoutineLabels := THashedStringList.Create;
  K_SHRoutineLabels.CaseSensitive := false;

  K_SetEnumVariants := TStringList.Create;

  SetLength(K_ExprNData, K_MaxParamInd);

  //*** Terminating Tokens List
  K_SHTermTokens := THashedStringList.Create;
  K_SHTermTokens.CaseSensitive := false;
  K_SHTermTokens.Add(K_sccFunctionDef);
  K_SHTermTokens.Add(K_sccRecordDef);
  K_SHTermTokens.Add(K_sccVarRecordDef);
  K_SHTermTokens.Add(K_sccProcedureDef);
  K_SHTermTokens.Add(K_sccDataDef);
  K_SHTermTokens.Add(K_sccStartBlock);
  K_SHTermTokens.Add(K_sccFinBlock);
  K_SHTermTokens.Add(K_sccLabel);
  K_SHTermTokens.Add(K_sccDataInit);
  K_SHTermTokens.Add(K_sccDataType);
  K_SHTermTokens.Add(K_sccClassConstructorDef);
  K_SHTermTokens.Add(K_sccClassDestructorDef);
  K_SHTermTokens.Add(K_sccImplementation);

  //*** Operators List
  K_SHOperators := THashedStringList.Create;
  K_SHOperators.CaseSensitive := false;
  K_SHOperators.Add(K_expSetOp);
  K_SHOperators.Add(K_expAddOp);
  K_SHOperators.Add(K_expSubOp);
  K_SHOperators.Add(K_expMultOp);
  K_SHOperators.Add(K_expDivOp);
  K_SHOperators.Add(K_expAndOp);
  K_SHOperators.Add(K_expOrOp);
  K_SHOperators.Add(K_expXorOp);
  K_SHOperators.Add(K_expNEOp);
  K_SHOperators.Add(K_expEQOp);
  K_SHOperators.Add(K_expGEOp);
  K_SHOperators.Add(K_expLTOp);
  K_SHOperators.Add(K_expLEOp);
  K_SHOperators.Add(K_expGTOp);

  //*** Functions List
  K_SHFunctions := THashedStringList.Create;
  K_SHFunctions.CaseSensitive := false;

  //*** Program Items List
  K_SHProgItemsList := THashedStringList.Create;
  K_SHProgItemsList.CaseSensitive := false;

// K_Script2
//**************** SPL BuildIn Funcs 140 - 159, 171 - 199
//**************** Free Inds 140-141, 159, 177-181,

  K_ExprNFuncNames[141] := 'GetCMDLinePar';
  K_ExprNFuncRefs [141] := K_ExprNGetCMDLinePar;

  K_ExprNFuncNames[142] := 'StringsAdd';
  K_ExprNFuncRefs [142] := K_ExprNStringsAdd;

  K_ExprNFuncNames[143] := 'StringsSet';
  K_ExprNFuncRefs [143] := K_ExprNStringsSet;

  K_ExprNFuncNames[144] := 'StringsDel';
  K_ExprNFuncRefs [144] := K_ExprNStringsDel;

  K_ExprNFuncNames[145] := 'StringsGet';
  K_ExprNFuncRefs [145] := K_ExprNStringsGet;

  K_ExprNFuncNames[146] := 'StringsLength';
  K_ExprNFuncRefs [146] := K_ExprNStringsLength;

  K_ExprNFuncNames[147] := 'StringsLoad';
  K_ExprNFuncRefs [147] := K_ExprNStringsLoad;

  K_ExprNFuncNames[148] := 'StringsSave';
  K_ExprNFuncRefs [148] := K_ExprNStringsSave;

  K_ExprNFuncNames[149] := 'Free';
  K_ExprNFuncRefs [149] := K_ExprNFree;

  K_ExprNFuncNames[150] := 'DVAddExpr';
  K_ExprNFuncRefs [150] := K_ExprNDVAddExpr;

  K_ExprNFuncNames[151] := 'DVMultExpr';
  K_ExprNFuncRefs [151] := K_ExprNDVMultExpr;

  K_ExprNFuncNames[152] := 'DVDivExpr';
  K_ExprNFuncRefs [152] := K_ExprNDVDivExpr;

  K_ExprNFuncNames[153] := 'DVCUSumExpr';
  K_ExprNFuncRefs [153] := K_ExprNDVCUSumExpr;

  K_ExprNFuncNames[154] := 'DVAbsExpr';
  K_ExprNFuncRefs [154] := K_ExprNDVAbsExpr;

  K_ExprNFuncNames[155] := 'DVSum';
  K_ExprNFuncRefs [155] := K_ExprNDVSum;

  K_ExprNFuncNames[156] := 'DVIndOfMax';
  K_ExprNFuncRefs [156] := K_ExprNDVIndOfMax;

  K_ExprNFuncNames[157] := 'DVMultExprE';
  K_ExprNFuncRefs [157] := K_ExprNDVMultExprE;

  K_ExprNFuncNames[158] := 'DVIndOfInterval';
  K_ExprNFuncRefs [158] := K_ExprNDVIndOfInterval;

//  K_ExprNFuncNames[159] := 'DVMode';
//  K_ExprNFuncRefs [159] := K_ExprNDVMode;

//  K_ExprNFuncNames[159] := 'DVPartValue';
//  K_ExprNFuncRefs [159] := K_ExprNDVPartValue;



//******************************************

  K_ExprNFuncNames[171] := 'SetOR';
  K_ExprNFuncRefs [171] := K_ExprNSetOR;

  K_ExprNFuncNames[172] := 'SetAND';
  K_ExprNFuncRefs [172] := K_ExprNSetAND;

  K_ExprNFuncNames[173] := 'SetClear';
  K_ExprNFuncRefs [173] := K_ExprNSetClear;

  K_ExprNFuncNames[174] := 'SetEQ';
  K_ExprNFuncRefs [174] := K_ExprNSetEQ;

  K_ExprNFuncNames[175] := 'SetLE';
  K_ExprNFuncRefs [175] := K_ExprNSetLE;

  K_ExprNFuncNames[176] := 'SetToInds';
  K_ExprNFuncRefs [176] := K_ExprNSetToInds;

//             ...


  K_ExprNFuncNames[180] := 'CreateMVAtlasArchive';
  K_ExprNFuncRefs [180] := K_ExprNCreateMVAtlasArchive;

  K_ExprNFuncNames[181] := 'RunDFPLStrings';
  K_ExprNFuncRefs [181] := K_ExprNRunDFPLStrings;

  K_ExprNFuncNames[182] := 'SetUDFields';
  K_ExprNFuncRefs [182] := K_ExprNSetUDFields;

  K_ExprNFuncNames[183] := 'GetUDFields';
  K_ExprNFuncRefs [183] := K_ExprNGetUDFields;

  K_ExprNFuncNames[184] := 'ApplicationTerminate';
  K_ExprNFuncRefs [184] := K_ExprNAppTerm;

  K_ExprNFuncNames[185] := 'SelectFilePath';
  K_ExprNFuncRefs [185] := K_ExprNSelectFilePath;

  K_ExprNFuncNames[186] := 'CreateIndIterator';
  K_ExprNFuncRefs [186] := K_ExprNCreateIndIterator;

  K_ExprNFuncNames[187] := 'AddIIDim';
  K_ExprNFuncRefs [187] := K_ExprNAddIIDim;

  K_ExprNFuncNames[188] := 'PrepIILoop';
  K_ExprNFuncRefs [188] := K_ExprNPrepIILoop;

  K_ExprNFuncNames[189] := 'GetNextIInds';
  K_ExprNFuncRefs [189] := K_ExprNGetNextIInds;

  K_ExprNFuncNames[190] := 'BuildCNKSets';
  K_ExprNFuncRefs [190] := K_ExprNBuildCNKSets;

  K_ExprNFuncNames[191] := 'ClearSetsBySets';
  K_ExprNFuncRefs [191] := K_ExprNClearSetsBySets;

  K_ExprNFuncNames[192] := 'CreateMSDoc';
  K_ExprNFuncRefs [192] := K_ExprNCreateMSDoc;

  K_ExprNFuncNames[193] := 'OpenCurArchive1';
  K_ExprNFuncRefs [193] := K_ExprNOpenCurArch1;

  K_ExprNFuncNames[194] := 'SaveCurArchive1';
  K_ExprNFuncRefs [194] := K_ExprNSaveCurArch1;

  K_ExprNFuncNames[195] := 'OpenCurArchive';
  K_ExprNFuncRefs [195] := K_ExprNOpenCurArch;

  K_ExprNFuncNames[196] := 'SaveCurArchive';
  K_ExprNFuncRefs [196] := K_ExprNSaveCurArch;

  K_ExprNFuncNames[197] := 'CreateWebSite';
  K_ExprNFuncRefs [197] := K_ExprNCreateWebSite;

  K_ExprNFuncNames[198] := 'MVImportTab';
  K_ExprNFuncRefs [198] := K_ExprNMVImportTab;

  K_ExprNFuncNames[199] := 'SetArchUndoMode';
  K_ExprNFuncRefs [199] := K_ExprNSetArchUndoMode;

Finalization
  K_ScriptLDDataTokenizer.Free;
  K_PascalHandles.Free;
  K_SHBaseTypesList.Free;
  K_TypeDescrsList.Free;
  K_ST.Free;
  K_SPT.Free;
  K_SHUsedRLData.Free;
  K_SHRoutineLabels.Free;
  K_SetEnumVariants.Free;
  K_SHTermTokens.Free;
  K_SHOperators.Free;
  K_SHFunctions.Free;
  K_SHProgItemsList.Free;
end.
