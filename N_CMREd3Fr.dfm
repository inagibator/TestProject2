object N_CMREdit3Frame: TN_CMREdit3Frame
  Left = 0
  Top = 0
  Width = 282
  Height = 171
  Constraints.MinHeight = 80
  Constraints.MinWidth = 70
  Color = clBtnShadow
  ParentBackground = False
  ParentColor = False
  TabOrder = 0
  OnDragOver = FrameDragOver
  OnEndDrag = FrameEndDrag
  OnMouseDown = FrameMouseDown
  OnMouseMove = FrameMouseMove
  DesignSize = (
    282
    171)
  object FrameLeftCaption: TLabel
    Left = 5
    Top = 3
    Width = 83
    Height = 13
    Caption = 'FrameLeftCaption'
    OnMouseDown = FrameMouseDown
  end
  object FrameRightCaption: TLabel
    Left = 162
    Top = 3
    Width = 87
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = 'FrameRighCaption'
    OnMouseDown = FrameMouseDown
  end
  object ImgClibrated: TImage
    Left = 80
    Top = 0
    Width = 18
    Height = 18
    Transparent = True
    Visible = False
    OnMouseDown = FrameMouseDown
  end
  object FinishEditing: TSpeedButton
    Left = 261
    Top = 0
    Width = 18
    Height = 18
    Hint = 'Close opened image'
    Anchors = [akTop, akRight]
    Caption = 'Close'
    Flat = True
    Glyph.Data = {
      C20D0000424DC20D000000000000360000002800000044000000110000000100
      1800000000008C0D000000000000000000000000000000000000D2D8EA3451A7
      1B3A981F3E9D203F9D213F9B203F9B21409E1B3EA1193DA2183DA4153AA11338
      A11137A310359E2B499ED1D7E7BEC6E03259C81A45C21E47C22049C2224CC220
      4BC4224CC62453D02354D02357D32052D11E55D61D52D5174BCF2E58C5BDC4DB
      BEC6E03259C81A45C21E47C22049C2224CC2204BC4224CC62453D02354D02357
      D32052D11E55D61D52D5174BCF2E58C5BDC4DBD5DAE83D5BAD2349B1254CB625
      4CB6254CB6254CB6254DB7264EB82750BA2750BA2751BB2751BB2751BB2750BA
      4265C1D5DDF13758BD2348BB2A4DBB3155BF3456BF3557BF3355BF3357C02C56
      C42753C32450C4204EC21B4BC31747C21443BE123CB02B499E335FDE2354E529
      59E32E5BE3315FE33360E33362E33664E33C72E83B73EB3B75EB3973EB3572ED
      2E6CED2661E91D54DC2E56C4335FDE2354E52959E32E5BE3315FE33360E33362
      E33664E33C72E83B73EB3B75EB3973EB3572ED2E6CED2661E91D54DC2E56C43D
      569B2447A8254CB4254CB6254CB6254CB6254CB6264DB72751BB2953BE2954BF
      2956C02A56C12A56C02953BE2852BC4165C1204AC52D54C9385DCC3F63CD4365
      CF4468D04165CF4166CF3663D23060D12B5DD22659D12055D11B50CF164BCB13
      42BE0F329A2054F02B5CF03463F13967EF3E6CF0406BF0426EEF4575F05086F0
      4F89F14E8AF14A8AF24385F23B7FF33174F22660E81749CC2054F02B5CF03463
      F13967EF3E6CF0406BF0426EEF4575F05086F04F89F14E8AF14A8AF24385F23B
      7FF33174F22660E81749CC21418D254AA8264DB4254CB6254CB6264DB7264DB7
      264FB92852BC2A56C12B58C22B58C22B59C32B58C22A57C12953BE2750BA2650
      CA365DCF4065D0486AD34C6ED54C6FD54A6ED4496ED53D6AD63667D63165D62C
      60D6245BD51F57D3194FD01546C211369F2459F53364F53C6CF4436EF34772F3
      4874F34C78F3527EF25D93F25D97F25A97F15695F14F92F2458BF23A7FF32C6B
      ED1C4FD12459F53364F53C6CF4436EF34772F34874F34C78F3527EF25D93F25D
      97F25A97F15695F14F92F2458BF23A7FF32C6BED1C4FD124428E274CA9274EB4
      264DB5254CB5264DB6264DB7264FB92852BD2A57C12B59C32C59C32C5BC52C5A
      C42B58C22955C02751BB2952CB3E61D0496BD35070D4FFFFFFFFFFFF5174D650
      74D6426FD63B6BD73568D7FFFFFFFFFFFF215AD41D53D01848C31237A0295CF5
      3A6AF44370F34A75F3FFFFFFFFFFFF527CF25884F1659AF1659EF163A1F1FFFF
      FFFFFFFF4C90F34083F22F6FED1E51D2295CF53A6AF44370F34A75F3FFFFFFFF
      FFFF527CF25884F1659AF1659EF163A1F1FFFFFFFFFFFF4C90F34083F22F6FED
      1E51D2264590294CA9284EB4264DB6889ADF889ADF264EB7274FB92953BE2B58
      C22C5AC4889ADF889ADF2C5BC52B59C32A56C02751BB3057CD4668D25070D457
      75D6FFFFFFFFFFFFFFFFFF5375D64570D73E6DD8FFFFFFFFFFFFFFFFFF245BD5
      2056D11D4DC4153AA12E60F4416DF34B74F34F7AF2FFFFFFFFFFFFFFFFFF5B86
      F1679CF0679FF0FFFFFFFFFFFFFFFFFF4F93F24385F23572ED2052D12E60F441
      6DF34B74F34F7AF2FFFFFFFFFFFFFFFFFF5B86F1679CF0679FF0FFFFFFFFFFFF
      FFFFFF4F93F24385F23572ED2052D126468F294DA8274DB3264DB6889ADF889A
      DF889ADF264FB92953BE2B58C2889ADF889ADF889ADF2C5AC42B58C22955C027
      51BB365DCF4C6ED45575D65C7BD85D7BD8FFFFFFFFFFFFFFFFFF4570D7FFFFFF
      FFFFFFFFFFFF2C60D6295ED42659D12250C5193CA23463F54672F24F7AF2547D
      F2577DF1FFFFFFFFFFFFFFFFFF6799F0FFFFFFFFFFFFFFFFFF5897F15292F247
      86F23A73EB2355D03463F54672F24F7AF2547DF2577DF1FFFFFFFFFFFFFFFFFF
      6799F0FFFFFFFFFFFFFFFFFF5897F15292F24786F23A73EB2355D027468E2A4E
      A8284EB4274DB5254BB4889ADF889ADF889ADF2852BD889ADF889ADF889ADF2C
      5AC42B59C32B58C22955BF2750BA3B60CF5272D55C7AD85F7DD9607CD95E7CD8
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3364D52D60D52B5ED42A5CD12854C51D40
      A23766F44D76F2557DF1587FF15B82F15880F1FFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF5895F15592F1508CF24984F23C74E92757D03766F44D76F2557DF1587FF1
      5B82F15880F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5895F15592F1508CF24984
      F23C74E92757D027458B2B4EA6294EB3274CB4244AB3254BB4889ADF889ADF88
      9ADF889ADF889ADF2B58C22B59C32B58C22A56C12854BE2750BA4B6DD46581DA
      6984DB6983DB657FD9607DD95C7AD7FFFFFFFFFFFFFFFFFF3862D23561D2315D
      D1345FD13660D0345AC42645A13C6CF4537BF25A82F15D83F25D83F25C82F15A
      84F1FFFFFFFFFFFFFFFFFF558EF1528BF24E8AF24C87F34881F13E73E92957CD
      3C6CF4537BF25A82F15D83F25D83F25C82F15A84F1FFFFFFFFFFFFFFFFFF558E
      F1528BF24E8AF24C87F34881F13E73E92957CD314F872E53B3284DB3264AB225
      4AB2244AB4254BB5889ADF889ADF889ADF2852BD2953BE2953BE2854BE2852BD
      2751BB264EB85474D66C87DB6E88DB6C87DB6781DA617CDAFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFF355ED0345CD0365ED03960CE385CC42847A14E78F2678BF06C
      8EF06A8BF06689F06087F1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3C70F43C70F4
      3E70F34070F13A69E52951C54E78F2678BF06C8EF06A8BF06689F06087F1FFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFF3C70F43C70F43E70F34070F13A69E52951C531
      4F873A5CA6385CB32F55B2284DB2254AB1889ADF889ADF889ADF889ADF889ADF
      264FB9274FB9274FB9264FB9264EB8264DB75474D6738DDD758FDE718ADD6A84
      DBFFFFFFFFFFFFFFFFFF4669D3FFFFFFFFFFFFFFFFFF3860D13A60D03C61CF39
      5DC329469F4F7AF26D8FF07392EF6F90EF6B8DF0FFFFFFFFFFFFFFFFFF4674F2
      FFFFFFFFFFFFFFFFFF3A6DF43C6CF43C6CF13965E42950C44F7AF26D8FF07392
      EF6F90EF6B8DF0FFFFFFFFFFFFFFFFFF4674F2FFFFFFFFFFFFFFFFFF3A6DF43C
      6CF43C6CF13965E42950C43452873F60A73E61B3355AB42E52B3889ADF889ADF
      889ADF294FB7889ADF889ADF889ADF264EB7264DB7264DB7264DB7254CB65B79
      D87992DF7B95DF758FDEFFFFFFFFFFFFFFFFFF5B77D7496BD34467D2FFFFFFFF
      FFFFFFFFFF3D63D13D61CE3B5DC42A479F547DF27795EE7B9AEE7695EEFFFFFF
      FFFFFFFFFFFF5A80F14773F3426FF3FFFFFFFFFFFFFFFFFF3B6BF43A6CF23863
      E32850C4547DF27795EE7B9AEE7695EEFFFFFFFFFFFFFFFFFF5A80F14773F342
      6FF3FFFFFFFFFFFFFFFFFF3B6BF43A6CF23863E32850C43754874465A84266B5
      3B61B6889ADF889ADF889ADF2E53B72E55B92D53B9889ADF889ADF889ADF264D
      B5264DB7254CB6254CB65F7DD9839BE1869DE27B94DFFFFFFFFFFFFF657FD960
      7BD94F6ED4496BD34768D3FFFFFFFFFFFF4064D14064CE3B5EC42A479F587FF1
      7E9AED839EED7D98EDFFFFFFFFFFFF6589F15E84F14D76F24672F24470F3FFFF
      FFFFFFFF3D6BF33C6AF03862E32750C5587FF17E9AED839EED7D98EDFFFFFFFF
      FFFF6589F15E84F14D76F24672F24470F3FFFFFFFFFFFF3D6BF33C6AF03862E3
      2750C5385685486AA9496DB54468B7889ADF889ADF3C61BB3A61BC375DBD345B
      BC3158BB889ADF889ADF2950B7274EB7264DB7254CB66582DA91A5E496AAE689
      9FE37B94DF758FDE708ADD6A85DB5E7CD85977D65876D65272D54E6FD4496BD3
      4466D0395CC225449E6085F188A2EC8EA8EC86A1EC7C99EE7693EE6D8FF0688B
      F05A80F1547DF2527CF24E77F24A75F34470F33F6CF03662E3244EC46085F188
      A2EC8EA8EC86A1EC7C99EE7693EE6D8FF0688BF05A80F1547DF2527CF24E77F2
      4A75F34470F33F6CF03662E3244EC43B58884B6CA85275B84D71BA4970BC486E
      BF476DC0476EC14269C24065C23A60C0355CBE2F57BB2C53B92950B8284FB826
      4DB7718BDD9FB2E7A1B4E891A5E4849BE17C95DF7890DE738DDD6D88DC6984DB
      6581DA5F7CD85A79D75172D44668D13759C222409C688AF094A9EC97ACEB8EA8
      EC839CED7C99EE7693EE7090EF678BF06388F15F85F1587FF1537BF24B74F341
      6DF03360E3214AC3688AF094A9EC97ACEB8EA8EC839CED7C99EE7693EE7090EF
      678BF06388F15F85F1587FF1537BF24B74F3416DF03360E3214AC33E5A8A4D70
      A85579B65578BB5376BC5175BE5277C15177C24C73C4476DC24066C03960BD33
      5BBB3056B92C52B7294FB5264CB38198E198ABE69CAEE78EA4E48098E07992DE
      748EDE728CDD6A86DB6582DA6380D95D7CD85776D64E6FD44266D03357C03C58
      A96E90EF8DA6ED91A8EC87A2EC7C99EE7695EE7090EF6C8EF06388F15E84F15B
      82F1567DF14F7AF24672F23B69F02F5CE3385DC96E90EF8DA6ED91A8EC87A2EC
      7C99EE7695EE7090EF6C8EF06388F15E84F15B82F1567DF14F7AF24672F23B69
      F02F5CE3385DC96471934B6A9C5172A95374AE5074AF5173B24F73B45175B74B
      6FB8476BB74265B63B60B43459B13156B02B51AC284DAA405DAEDEE3F67D96DF
      6D88DC627FD95B79D85574D65070D45272D54A6CD34A6CD34367D14367D13F62
      D1385DCE3057CA4261C1D4DAECC8D0E76D8FF0688AF05E83F1557DF1527CF24C
      76F34D76F24672F24370F33E6BF33E6BF33A6AF43464F52E5FF03C66E0BFC7DE
      C8D0E76D8FF0688AF05E83F1557DF1527CF24C76F34D76F24672F24370F33E6B
      F33E6BF33A6AF43464F52E5FF03C66E0BFC7DED6DBEA657394415F9042629342
      5F9240619543629744649B3F5F9C3B5C9E37579B3152992E4D972A4B97254490
      415A9DD6DBEA}
    Margin = 0
    NumGlyphs = 4
    OnClick = FinishEditingClick
  end
  object ImgHasDiagn: TImage
    Left = 99
    Top = 0
    Width = 18
    Height = 18
    Transparent = True
    Visible = False
    OnMouseDown = FrameMouseDown
  end
  inline RFrame: TN_MapEdFrame
    Left = 2
    Top = 18
    Width = 278
    Height = 151
    HelpType = htKeyword
    Anchors = [akLeft, akTop, akRight, akBottom]
    Constraints.MinHeight = 56
    Constraints.MinWidth = 56
    Color = clBtnFace
    ParentBackground = False
    ParentColor = False
    TabOrder = 0
    inherited PaintBox: TPaintBox
      Width = 262
      Height = 135
      OnDblClick = FrameDblClick
      OnDragOver = FrameDragOver
    end
    inherited HScrollBar: TScrollBar
      Top = 135
      Width = 278
    end
    inherited VScrollBar: TScrollBar
      Left = 262
      Height = 135
    end
  end
  object STReadOnly: TStaticText
    Left = 121
    Top = 2
    Width = 12
    Height = 17
    Alignment = taCenter
    Caption = 'R'
    Color = clLime
    ParentColor = False
    TabOrder = 1
    Visible = False
  end
  object CMREd3FrActList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 8
    Top = 64
    object aFileSaveSlideA: TAction
      Category = 'Image'
      Caption = 'Save Slide to Archive'
      Hint = 'Save Slide to Archive'
      ImageIndex = 6
      Visible = False
      OnExecute = aFileSaveSlideAExecute
    end
    object aFilePasteFromFile: TAction
      Category = 'Image'
      Caption = 'Paste Image from Image File'
      Hint = 'Paste Image from Image File'
      ImageIndex = 4
      OnExecute = aFilePasteFromFileExecute
    end
    object aFileReplaceImageF: TAction
      Category = 'Image'
      Caption = 'Replace Image by Image File'
      Hint = 'Replace Image by Image File'
      ImageIndex = 4
      OnExecute = aFileReplaceImageFExecute
    end
    object aFileReplaceSlideF: TAction
      Category = 'Image'
      Caption = 'Replace Slide by Slide File'
      Hint = 'Replace Slide by Slide File'
      ImageIndex = 4
      OnExecute = aFileReplaceSlideFExecute
    end
    object aDebCMSOneSlideChild: TAction
      Category = 'Debug'
      Caption = 'CMS API in Child mode'
      Hint = 'CMS API in Child mode'
      ImageIndex = 19
    end
    object aFileSaveImageF: TAction
      Category = 'Image'
      Caption = 'Save Image To Image File'
      Hint = 'Save Image To Image File'
      ImageIndex = 5
      OnExecute = aFileSaveImageFExecute
    end
    object aFileSaveSlideF: TAction
      Category = 'Image'
      Caption = 'Save Slide To Slide File'
      Hint = 'Save Slide To Slide File'
      ImageIndex = 5
      OnExecute = aFileSaveSlideFExecute
    end
    object aEditCopySelected: TAction
      Category = 'Edit'
      Caption = 'Copy Selected Region to Clipboard'
      Hint = 'Copy Selected Region to Clipboard'
      ImageIndex = 131
      OnExecute = aEditCopySelectedExecute
    end
    object aFilePrint: TAction
      Category = 'Image'
      Caption = 'Print  ...'
      Enabled = False
      Hint = 'Print Slide'
      ImageIndex = 10
      OnExecute = aFilePrintExecute
    end
    object aDebSaveArchAs: TAction
      Category = 'Debug'
      Caption = 'Save Archive As  ...'
      Hint = 'Save Archive As  ...'
      ImageIndex = 3
    end
    object aDebShowNVTreeForm: TAction
      Category = 'Debug'
      Caption = 'Show NVTree Form'
      Hint = 'Show NVTree Form'
      ImageIndex = 45
    end
    object aEditCopyWhole: TAction
      Category = 'Edit'
      Caption = 'Copy Whole Image to Clipboard'
      Hint = 'Copy Whole Image to Clipboard'
      OnExecute = aEditCopyWholeExecute
    end
    object aEditPasteInSelection: TAction
      Category = 'Edit'
      Caption = 'Paste Image from Clipboard'
      Hint = 'Paste Image from Clipboard'
      ImageIndex = 132
      OnExecute = aEditPasteInSelectionExecute
    end
    object aEditPasteWhole: TAction
      Category = 'Edit'
      Caption = 'Replace Image by Clipboard'
      Hint = 'Replace Image by Clipboard'
      OnExecute = aEditPasteWholeExecute
    end
    object aEditCropBySelection: TAction
      Category = 'Edit'
      Caption = 'Crop Image By Selection'
      Hint = 'Crop Image By Selection'
      OnExecute = aEditCropBySelectionExecute
    end
    object aViewFitToWindow: TAction
      Category = 'View'
      Caption = 'Fit To Window'
      ImageIndex = 212
    end
    object aViewView1To1: TAction
      Category = 'View'
      Caption = 'View 1:1'
      Hint = 'View 1:1'
      ImageIndex = 222
    end
    object aViewShowResHist: TAction
      Category = 'View'
      Caption = 'Show Resulting Histogramm'
      Hint = 'Show Resulting Histogramm'
    end
    object aAdjustBrighByTwoPoints: TAction
      Category = 'Adjust'
      Caption = 'Brightness by Two Points'
      Hint = 'Adjust Brightness'
    end
    object aAdjustBrighByGammaCorr: TAction
      Category = 'Adjust'
      Caption = 'Brightness by Gamma Correction'
      Hint = 'Brightness Gamma Correction'
    end
    object aAdjustResample: TAction
      Category = 'Adjust'
      Caption = 'Resample'
    end
    object aAdjustFlipHorizontal: TAction
      Category = 'Adjust'
      Caption = 'Flip Horizontal'
    end
    object aAdjustFlipVertical: TAction
      Category = 'Adjust'
      Caption = 'Flip Vertical'
    end
    object aAdjustRotate90CW: TAction
      Category = 'Adjust'
      Caption = 'Rotate 90'#176' CW'
      Hint = 'Rotate 90'#176' CW'
    end
    object aAdjustRotate90CCW: TAction
      Category = 'Adjust'
      Caption = 'Rotate 90'#176' CCW'
      Hint = 'Rotate 90'#176' CCW'
    end
    object aAdjustSrcHistVisible: TAction
      Category = 'Adjust'
      Caption = 'Source Histogramm Visible'
      Hint = 'Toggle Source Histogramm Visibility'
    end
    object aDeb1: TAction
      Category = 'Debug'
      Caption = 'aDeb1'
      ImageIndex = 95
    end
    object aObjBeginEditing: TAction
      Category = 'Objects'
      Caption = 'Begin Editing Objects'
      Hint = 'Begin Editing Objects'
    end
    object aObjFinishEditing: TAction
      Category = 'Objects'
      Caption = 'Finish Editing Objects'
      Hint = 'Begin Editing Objects'
    end
    object aObjAddTextNote: TAction
      Category = 'Objects'
      Caption = 'Add Text Note Object'
      Hint = 'Add Text Note Object'
    end
    object aObjAddRoundRect: TAction
      Category = 'Objects'
      Caption = 'Add Round Rect Object'
      Hint = 'Add Round Rect Object'
    end
    object aObjAddArrow: TAction
      Category = 'Objects'
      Caption = 'Add Arrow Object'
      Hint = 'Add Arrow Object'
    end
    object aObjPasteObject: TAction
      Category = 'Objects'
      Caption = 'Paste Object'
    end
    object aObjDeleteAllObj: TAction
      Category = 'Objects'
      Caption = 'Delete All Objects'
      Hint = 'Delete All Objects'
    end
    object aObjObjectsVisible: TAction
      Category = 'Objects'
      AutoCheck = True
      Caption = 'Objects are Visible'
      Hint = 'Objects are Visible'
    end
    object aDeb2: TAction
      Category = 'Debug'
      Caption = 'aDeb2'
      ImageIndex = 96
    end
    object aMesCalibrate: TAction
      Category = 'Measure'
      Caption = 'Calibrate Slide'
      Hint = 'Calibrate Slide'
    end
    object aMesMeasureDistance: TAction
      Category = 'Measure'
      Caption = 'Measure Distance'
      Hint = 'Measure Distance'
    end
    object aAdjustClearImage: TAction
      Category = 'Adjust'
      Caption = 'Clear Image'
    end
    object aObjTst: TAction
      Category = 'Objects'
      Caption = 'aObjTst'
      OnExecute = aObjTstExecute
    end
    object aViewTst: TAction
      Category = 'View'
      Caption = 'aViewTst'
    end
  end
end
