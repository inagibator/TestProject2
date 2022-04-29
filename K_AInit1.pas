unit K_AInit1;

interface

implementation

uses Forms,
  K_Parse, K_FrRAEdit, K_RAEdit;

Initialization
// K_FrRAEdit
//  Application.HintHidePause := 20000;
//  Application.HintHidePause := 2000;
  Application.HintHidePause := 10000;
{!!! убраны круглые скобки
  K_RAFEDParsTokenizer := TK_Tokenizer.Create( '', ' '+#$A#$D#9+'),',
      '""'+''''''+'()' );
  K_RAFEDParsTokenizer.setEnclosedBracketsInd( 5 );
}
  K_RAFEDParsTokenizer := TK_Tokenizer.Create( '', ' '+#$A#$D#9+'],',
      '""'+''''''+'[]' );
  K_RAFEDParsTokenizer.setNestedBracketsInd( 5 );

// K_RAEdit
  K_RAFUDRefDefPathObj := nil;
  K_RegRAFViewer( 'RAFColorViewer', TK_RAFColorViewer );
  K_RegRAFViewer( 'RAFUDRefV',  TK_RAFUDRefViewer );
  K_RegRAFViewer( 'RAFUDRefV1', TK_RAFUDRefViewer1 );


  K_RegRAFViewer( 'RAFSwitchEnabling',  TK_RAFSwitchEnablingViewer );
  K_RegRAFViewer( 'RAFColorArray',  TK_RAFColorArrayViewer );
  K_RegRAFViewer( 'RAFUDRAV',  TK_RAFUDRAViewer );
  K_RegRAFViewer( 'RAFRecord',  TK_RAFRecViewer );
  K_RegRAFViewer( 'RAFFileName',  TK_RAFFNameViewer1 );
  K_RegRAFViewer( 'RAFNFontViewer', TK_RAFNFontViewer );

  K_RegRAFEditor( 'RAFColorEditor', TK_RAFColorDialogEditor );
  K_RegRAFEditor( 'RAFUDRef', TK_RAFUDRefEditor );
  K_RegRAFEditor( 'RAFUDRefF', TK_RAFUDRefEditor1 );
  K_RegRAFEditor( 'RAFExtCmB', TK_RAFExtCmBEditor );
  K_RegRAFEditor( 'RAFUDRAE',  TK_RAFUDRAEditor );
  K_RegRAFEditor( 'RAFSArrEditor',  TK_RAFSArrayEditor );
  K_RegRAFEditor( 'RAFUDRARef', TK_RAFUDRARefEditor );
  K_RegRAFEditor( 'RAFFNameEditor', TK_RAFFNameEditor );
  K_RegRAFEditor( 'RAFFileName', TK_RAFFNameEditor1 );
  K_RegRAFEditor( 'RAFFNameCmBEditor', TK_RAFFNameCmBEditor );
  K_RegRAFEditor( 'RAFDateTimePicEditor', TK_RAFDateTimePicEditor );
  K_RegRAFEditor( 'RAFUDBase', TK_RAFUDEditor );
  K_RegRAFEditor( 'RAFVArrayEditor', TK_RAFVArrayEditor );

Finalization
  K_RAFEDParsTokenizer.Free;

end.
