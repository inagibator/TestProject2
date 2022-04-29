unit K_AUDTreeInit;

interface

implementation

uses Classes, SysUtils, inifiles,
  N_ClassRef, K_parse, K_CLib0, K_UDConst, K_UDT2, K_UDT1, K_UDC, K_STBuf, K_SBuf;

Initialization
// K_SBuf
N_SerialBuf := TN_SerialBuf.Create;

// K_STBuf
K_SerialTextBuf := TK_SerialTextBuf.Create;

// K_UDC
{
  K_DefaultTreeMerge := TK_TreeMerge.Create();
  K_DefaultTreeMerge.updateFlags.DirFlags :=
        K_fuUseGlobal or K_fuUseCurrent or
        K_fuDirMergeClearOld or K_fuDirMergeUniqObjNameNone;
  K_DefaultTreeMerge.updateFlags.EntryFlags :=
        K_fuUseGlobal or K_fuUseCurrent;
}

  K_AppUDGPathsList := THashedStringList.Create;
  K_AppInfoList := TStringList.Create;

// K_UDT1
{
 // debug initialization
var
  F:TextFile;
}

{
 // debug initialization
  N_DebGroups[3].DSInd := 0;
  N_DebStreams[0].DSName := 'E:\delphi_prj_new\deb1.txt';
  Assign( F, N_DebStreams[0].DSName );
  Rewrite( F );
  Flush( F );
  Close( F );
  N_AddDebString( 3, '0001 Debug Protocol from  ' + DateTimeToStr( Date+Time ) );
}

  N_ClassRefArray[$00] := TN_UDBase; // N_EmptyObject

  N_ClassRefArray[N_UDBaseCI] := TN_UDBase;
  N_ClassTagArray[N_UDBaseCI] := 'Node';

  N_ClassRefArray[N_UDMemCI]  := TN_UDMem;
  N_ClassTagArray[N_UDMemCI]  := 'UDMem';

  N_ClassRefArray[N_UDExtMemCI] := TN_UDExtMem;
  N_ClassTagArray[N_UDExtMemCI] := 'UDExtMem';

  K_UDPathTokenizer := TK_Tokenizer.Create( '', K_udpDelims2 );
//  K_UDPathTokenizer.setBrackets( '' );

//  K_UDGetPathIter := TK_UDIter.Create( nil,
//    [], K_UDFilterSearchEqual, K_UDFilterSearchDown );

  K_UDCursorsList := TStringList.Create( );
  K_UDCursorsList.Sorted := true;

  K_SysDateTime := Now();

  K_UDLoopProtectionList := TList.Create;

// K_UDT2
  K_UDCursorForcePathDefUDCI := N_UDBaseCI;

  N_ClassRefArray[K_UDRefCI]  := TK_UDRef;
  N_ClassTagArray[K_UDRefCI]  := 'Ref';

Finalization
  N_SerialBuf.Free;
  K_SerialTextBuf.Free;
  K_AppUDGPathsList.Free;
  K_AppInfoList.Free;
  K_UDPathTokenizer.Free;
  K_UDCursorsList.Free;
  K_UDLoopProtectionList.Free;

end.
