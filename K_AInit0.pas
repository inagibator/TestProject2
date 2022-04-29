unit K_AInit0;

interface

implementation

uses inifiles, Classes,
  K_Parse, K_CLib0, K_Arch;

Initialization
// K_CLib0
  K_MRProcess := TK_MRProcess.Create;

  K_CharNumList := TStringList.Create;
  K_CharNumList.CaseSensitive := true;
  K_PrepCharNumList( K_NumCharTab0 );

  K_CompareKeyAndStrTokenizer := TK_Tokenizer.Create( '' );

// K_Arch
  K_AppFileGPathsList := THashedStringList.Create;
  K_ArchInfoList := TStringList.Create( );

Finalization
// K_CLib0
  K_MRProcess.Free;
  K_CharNumList.Free;
  K_CompareKeyAndStrTokenizer.Free;

// K_Arch
  K_AppFileGPathsList.Free;
  K_ArchInfoList.Free;

end.
