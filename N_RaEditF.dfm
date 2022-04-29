inherited N_RAEditForm: TN_RAEditForm
  Left = 282
  Top = 326
  AutoScroll = False
  Caption = 'N_RAEditForm'
  ClientHeight = 189
  ClientWidth = 326
  Constraints.MinHeight = 240
  Constraints.MinWidth = 300
  Menu = MainMenu1
  ShowHint = True
  DesignSize = (
    326
    189)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 316
    Top = 179
    TabOrder = 5
  end
  inline RAEditFrame: TK_FrameRAEdit
    Left = 0
    Top = 87
    Width = 326
    Height = 55
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    inherited SGrid: TStringGrid
      Width = 326
      Height = 55
    end
    inherited BtExtEditor_1: TButton
      Left = 56
      Top = 64
    end
    inherited ActList: TActionList
      Left = 80
      Top = 56
    end
  end
  object bnCancel: TButton
    Left = 235
    Top = 146
    Width = 42
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 1
    OnClick = bnCancelClick
  end
  object bnOK: TButton
    Left = 279
    Top = 146
    Width = 42
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 2
    OnClick = bnOKClick
  end
  object bnApply: TButton
    Left = 191
    Top = 146
    Width = 42
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Apply'
    TabOrder = 3
    OnClick = bnApplyClick
  end
  object ToolBarOwn: TToolBar
    Left = 0
    Top = 0
    Width = 326
    Height = 29
    ButtonHeight = 38
    ButtonWidth = 25
    Caption = 'ToolBarOwn'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 4
    object ToolButton2: TToolButton
      Left = 0
      Top = 2
      Action = aEdCopySelected
    end
    object ToolButton3: TToolButton
      Left = 25
      Top = 2
      Action = aEdPasteInsteadOfSelected
    end
    object bnSetUObj: TToolButton
      Left = 50
      Top = 2
      Action = aCompViewExecute
    end
    object ToolButton10: TToolButton
      Left = 75
      Top = 2
      Width = 8
      Caption = 'ToolButton10'
      ImageIndex = 123
      Style = tbsSeparator
    end
    object tbIndEdit1: TToolButton
      Left = 83
      Top = 2
      Caption = 'tbIndEdit1'
      ImageIndex = 128
    end
    object tbIndEdit2: TToolButton
      Left = 108
      Top = 2
      Caption = 'tbIndEdit2'
      ImageIndex = 129
    end
    object tbIndFieldEd1: TToolButton
      Left = 133
      Top = 2
      Caption = 'tbIndFieldEd1'
      ImageIndex = 130
    end
    object ToolButton15: TToolButton
      Left = 158
      Top = 2
      Action = aViewObjHelp
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 170
    Width = 326
    Height = 19
    Panels = <>
  end
  object ToolBarComp: TToolBar
    Left = 0
    Top = 29
    Width = 326
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBarComp'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 7
    object tbCompSetParams: TToolButton
      Left = 0
      Top = 2
      Action = aCompSetParams
      Grouped = True
      Style = tbsCheck
    end
    object tbCompUserParams: TToolButton
      Left = 25
      Top = 2
      Action = aCompUserParams
      Grouped = True
      Style = tbsCheck
    end
    object tbCompExpParams: TToolButton
      Left = 50
      Top = 2
      Action = aCompExportParams
      Grouped = True
      Style = tbsCheck
    end
    object tbCompComParams: TToolButton
      Left = 75
      Top = 2
      Action = aCompCommonParams
      Grouped = True
      Style = tbsCheck
    end
    object tbCompLayout: TToolButton
      Left = 100
      Top = 2
      Action = aCompLayoutParams
      Grouped = True
      Style = tbsCheck
    end
    object tbCompCoords: TToolButton
      Left = 125
      Top = 2
      Action = aCompCoordsParams
      Grouped = True
      Style = tbsCheck
    end
    object tbCompPanel: TToolButton
      Left = 150
      Top = 2
      Action = aCompPanelParams
      Grouped = True
      Style = tbsCheck
    end
    object tbCompIndParams: TToolButton
      Left = 175
      Top = 2
      Action = aCompIndivParams
      Grouped = True
      Style = tbsCheck
    end
    object ToolButton11: TToolButton
      Left = 200
      Top = 2
      Action = RAEditFrame.RebuildGrid
    end
  end
  object ToolBarArray: TToolBar
    Left = 0
    Top = 58
    Width = 326
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 6
    object ToolButton4: TToolButton
      Left = 0
      Top = 2
      Action = RAEditFrame.RebuildGrid
    end
    object ToolButton5: TToolButton
      Left = 25
      Top = 2
      Action = RAEditFrame.TranspGrid
    end
    object ToolButton6: TToolButton
      Left = 50
      Top = 2
      Width = 5
      Caption = 'ToolButton3'
      ImageIndex = 80
      Style = tbsSeparator
    end
    object ToolButton7: TToolButton
      Left = 55
      Top = 2
      Action = aEdCreateNewRecords
    end
    object ToolButton1: TToolButton
      Left = 80
      Top = 2
      Action = aEdClearSelected
    end
    object ToolButton8: TToolButton
      Left = 105
      Top = 2
      Action = aEdDestroySelectedRecords
    end
    object ToolButton12: TToolButton
      Left = 130
      Top = 2
      Action = RAEditFrame.AddRow
    end
    object ToolButton13: TToolButton
      Left = 155
      Top = 2
      Action = RAEditFrame.InsRow
    end
    object ToolButton14: TToolButton
      Left = 180
      Top = 2
      Action = RAEditFrame.DelRow
    end
    object ToolButton9: TToolButton
      Left = 205
      Top = 2
      Width = 5
      Caption = 'ToolButton7'
      ImageIndex = 81
      Style = tbsSeparator
    end
    object ToolButton16: TToolButton
      Left = 210
      Top = 2
      Action = RAEditFrame.AddCol
    end
    object ToolButton17: TToolButton
      Left = 235
      Top = 2
      Action = RAEditFrame.InsCol
    end
    object ToolButton18: TToolButton
      Left = 260
      Top = 2
      Action = RAEditFrame.DelCol
    end
  end
  object cbApplyToMarked: TCheckBox
    Left = 7
    Top = 144
    Width = 75
    Height = 24
    Anchors = [akLeft, akBottom]
    Caption = 'To Marked'
    TabOrder = 8
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 152
    Top = 104
    object CompMMI: TMenuItem
      Caption = 'Comp'
      object ExecuteComponent1: TMenuItem
        Action = aCompViewExecute
      end
      object ViewComponentAsGDIPicture1: TMenuItem
        Action = aCompViewMain
      end
      object N4: TMenuItem
        Action = aCompViewByCurAux
      end
      object SetComponentAuxViewer1: TMenuItem
        Action = aCompViewSetCurAux
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object EditCompSettings1: TMenuItem
        Action = aCompSetParams
      end
      object EditCompUserParams1: TMenuItem
        Action = aCompUserParams
      end
      object ComponentExportParams1: TMenuItem
        Action = aCompExportParams
      end
      object EditComponentCommonParams1: TMenuItem
        Action = aCompCommonParams
      end
      object EditCompLayout1: TMenuItem
        Action = aCompLayoutParams
      end
      object EditCompCoords1: TMenuItem
        Action = aCompCoordsParams
      end
      object EditCompPanel1: TMenuItem
        Action = aCompPanelParams
      end
      object miEditCompIndividualParams: TMenuItem
        Action = aCompIndivParams
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object CreateComponentSettings1: TMenuItem
        Action = aEdCreateSetParams
      end
      object CreateComponentUserParams1: TMenuItem
        Action = aEdCreateUserParams
      end
      object CreateComponentExportParams1: TMenuItem
        Action = aEdCreateExportParams
      end
      object CreateComponentPanelParams1: TMenuItem
        Action = aEdCreatePanelParams
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object CopySelectedToClipboard1: TMenuItem
        Action = aEdCopySelected
      end
      object PasteInsteadOfSelected1: TMenuItem
        Action = aEdPasteInsteadOfSelected
      end
      object PasteInsideSelected2: TMenuItem
        Action = aEdPasteInsideSelected
      end
      object PasteInsideSelected1: TMenuItem
        Action = aEdPasteAndFillAllSelected
      end
      object N8: TMenuItem
        Action = RAEditFrame.SetPasteFromClipboardMode
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object CreateNewRecords1: TMenuItem
        Action = aEdCreateNewRecords
      end
      object ClearSelectedFields1: TMenuItem
        Action = aEdClearSelected
      end
      object DestroySelectedRecords1: TMenuItem
        Action = aEdDestroySelectedRecords
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object N10: TMenuItem
        Action = RAEditFrame.SendFVals
      end
    end
    object ArrayEdit1: TMenuItem
      Caption = 'Array Edit'
      object SetRArraySize1: TMenuItem
        Action = aAESetRArraySize
      end
      object Set2DRArrayDimensions1: TMenuItem
        Action = aAESet2DRArraySize
      end
      object SetAllRArraysSizes1: TMenuItem
        Action = aAESetRArraysSizes
      end
      object FillRArraybyTestData1: TMenuItem
        Action = aAEFillRArray
      end
      object Fill2DRArraybyTestData1: TMenuItem
        Action = aAEFill2DRArray
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object aAEEditAs1DRArray1: TMenuItem
        Action = aAEEditAs1DRArray
      end
      object EditAs2DRArray1: TMenuItem
        Action = aAEEditAs2DRArray
      end
    end
    object miOther: TMenuItem
      Caption = 'Special Edit'
      object CopyFullFieldName1: TMenuItem
        Action = aSECopyFullFieldName
      end
      object SetCSorCSCodes1: TMenuItem
        Action = aSESetCSAndCSCode
      end
      object SetUObjbySelectedUObj1: TMenuItem
        Action = aSESetUObj
      end
      object ImportUDTable1: TMenuItem
        Action = aSEImportUDTable
      end
      object ExportUDTable1: TMenuItem
        Action = aSEExportUDTable
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object ViewObjectHelp1: TMenuItem
        Action = aViewObjHelp
      end
      object aViewFieldInfo1: TMenuItem
        Action = aViewFieldInfo
      end
      object ViewEditObjInfo1: TMenuItem
        Action = aViewEditObjInfo
      end
      object N5: TMenuItem
        Action = RAEditFrame.RebuildGrid
        Caption = 'Rbuild Grid'
      end
    end
    object miDebug: TMenuItem
      Caption = 'Debug'
      object oggleStatDynParams1: TMenuItem
        Action = aDebToggleStatDyn
      end
      object ViewComponentSPLText1: TMenuItem
        Action = aDebEditCompSPLText
      end
      object ClearSelfRTI1: TMenuItem
        Action = aDebClearSelfRTI
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object aDebAction11: TMenuItem
        Action = aDebTmpAction1
      end
      object mpAction21: TMenuItem
        Action = aDebTmpAction2
      end
      object mpAction31: TMenuItem
        Action = aDebTmpAction3
      end
    end
  end
  object FormActions: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 192
    Top = 104
    object aCompViewExecute: TAction
      Category = 'Comp View'
      Caption = 'Execute Component'
      Hint = #1042#1099#1087#1086#1083#1085#1080#1090#1100' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1091
      ImageIndex = 99
      OnExecute = aCompViewExecuteExecute
    end
    object aCompViewMain: TAction
      Category = 'Comp View'
      Caption = 'View Component'
      ImageIndex = 8
      OnExecute = aCompViewMainExecute
    end
    object aCompViewByCurAux: TAction
      Category = 'Comp View'
      Caption = '???'
      ImageIndex = 8
      OnExecute = aCompViewByCurAuxExecute
    end
    object aCompViewSetCurAux: TAction
      Category = 'Comp View'
      Caption = 'Set Component Aux Viewer'
      ImageIndex = 42
      OnExecute = aCompViewSetCurAuxExecute
    end
    object aCompViewPictInMem: TAction
      Category = 'Comp View'
      Caption = 'View Component'
      ImageIndex = 33
    end
    object aCompViewPictFromFile: TAction
      Category = 'Comp View'
      Caption = 'View Pict. File  (Created by Comp.) '
      ImageIndex = 160
    end
    object aCompViewHTMLFile: TAction
      Category = 'Comp View'
      Caption = 'View Component'
      ImageIndex = 164
    end
    object aCompViewInExtBrowser: TAction
      Category = 'Comp View'
      Caption = 'View Component In Ext. Browser'
      ImageIndex = 109
    end
    object aCompViewInMSWord: TAction
      Category = 'Comp View'
      Caption = 'View Component In MS Word'
      ImageIndex = 165
    end
    object aCompSetParams: TAction
      Category = 'Comp Params'
      Caption = 'Edit Comp Settings Params'
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1088#1072#1089#1089#1099#1083#1082#1080' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1099
      ImageIndex = 56
      OnExecute = aCompSetParamsExecute
    end
    object aCompViewInMSExcel: TAction
      Category = 'Comp View'
      Caption = 'View Component In MS Word'
      ImageIndex = 166
    end
    object aCompViewAsSrcText: TAction
      Category = 'Comp View'
      Caption = 'View Component As Source Text'
      ImageIndex = 161
    end
    object aAESetRArraySize: TAction
      Category = 'Array Edit'
      Caption = 'Set RArray Size'
      Hint = #1048#1079#1084#1077#1085#1080#1090#1100' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1084#1072#1089#1089#1080#1074#1072
      ImageIndex = 108
      OnExecute = aAESetRArraySizeExecute
    end
    object aAESet2DRArraySize: TAction
      Category = 'Array Edit'
      Caption = 'Set 2D RArray Dimensions'
      ImageIndex = 92
      OnExecute = aAESet2DRArraySizeExecute
    end
    object aAESetRArraysSizes: TAction
      Category = 'Array Edit'
      Caption = 'Set All RArrays Sizes'
      Hint = #1048#1079#1084#1077#1085#1080#1090#1100' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1074#1089#1077#1093' '#1084#1072#1089#1089#1080#1074#1086#1074
      ImageIndex = 101
      OnExecute = aAESetRArraysSizesExecute
    end
    object aDebToggleStatDyn: TAction
      Category = 'Debug'
      Caption = 'Toggle Stat <-> Dyn Params'
      Hint = 'Toggle Static and Dynamic Params'
      ImageIndex = 58
      OnExecute = aDebToggleStatDynExecute
    end
    object aCompUserParams: TAction
      Category = 'Comp Params'
      Caption = 'Edit Comp User Params'
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100#1089#1082#1080#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1099
      ImageIndex = 89
      OnExecute = aCompUserParamsExecute
    end
    object aCompExportParams: TAction
      Category = 'Comp Params'
      Caption = 'Edit Comp Export Params'
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1101#1082#1089#1087#1086#1088#1090#1072' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1099
      ImageIndex = 127
      OnExecute = aCompExportParamsExecute
    end
    object aCompCommonParams: TAction
      Category = 'Comp Params'
      Caption = 'Edit Comp Common Params'
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1086#1073#1097#1080#1077' '#1076#1083#1103' '#1074#1089#1077#1093' '#1082#1086#1084#1087#1086#1085#1077#1085#1090' '#1087#1072#1072#1088#1084#1077#1090#1088#1099
      ImageIndex = 120
      OnExecute = aCompCommonParamsExecute
    end
    object aCompLayoutParams: TAction
      Category = 'Comp Params'
      Caption = 'Edit Comp Layout Params'
      Hint = 'Edit Component Layout'
      ImageIndex = 88
      OnExecute = aCompLayoutParamsExecute
    end
    object aCompCoordsParams: TAction
      Category = 'Comp Params'
      Caption = 'Edit Comp Coords Params'
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1082#1086#1086#1088#1076#1080#1085#1072#1090#1099' '#1074#1080#1079#1091#1072#1083#1100#1085#1086#1081' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1099
      ImageIndex = 84
      OnExecute = aCompCoordsParamsExecute
    end
    object aCompPanelParams: TAction
      Category = 'Comp Params'
      Caption = 'Edit Comp Panel Params'
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1072#1085#1077#1083#1080' '#1074#1080#1079#1091#1072#1083#1100#1085#1086#1081' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1099
      ImageIndex = 83
      OnExecute = aCompPanelParamsExecute
    end
    object aCompIndivParams: TAction
      Category = 'Comp Params'
      Caption = 'Edit Comp Individual Params'
      Hint = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1080#1085#1076#1080#1074#1080#1076#1091#1072#1083#1100#1085#1099#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1082#1086#1084#1087#1086#1085#1077#1085#1090#1099
      ImageIndex = 59
      OnExecute = aCompIndivParamsExecute
    end
    object aAEFillRArray: TAction
      Category = 'Array Edit'
      Caption = 'Fill RArray by Test Data'
      Hint = #1047#1072#1087#1086#1083#1085#1080#1090#1100' '#1101#1083#1077#1084#1077#1085#1090#1099' '#1084#1072#1089#1089#1080#1074#1072
      ImageIndex = 19
      OnExecute = aAEFillRArrayExecute
    end
    object aAEFill2DRArray: TAction
      Category = 'Array Edit'
      Caption = 'Fill 2D RArray by Test Data'
      ImageIndex = 19
      OnExecute = aAEFill2DRArrayExecute
    end
    object aSECopyFullFieldName: TAction
      Category = 'Special Edit'
      Caption = 'Copy Full Field Name'
      Hint = #1047#1087#1080#1089#1072#1090#1100' '#1074' '#1073#1091#1092#1077#1088' '#1086#1073#1084#1077#1085#1072' '#1087#1086#1083#1085#1086#1077' '#1080#1084#1103' '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1075#1086' '#1087#1086#1083#1103
      ImageIndex = 123
      OnExecute = aSECopyFullFieldNameExecute
    end
    object aViewFieldInfo: TAction
      Category = 'View'
      Caption = 'View Current Field Info '
      Hint = #1055#1086#1082#1072#1079#1072#1090#1100' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1102' '#1086' '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1084' '#1087#1086#1083#1077
      ImageIndex = 31
      OnExecute = aViewFieldInfoExecute
    end
    object aViewEditObjInfo: TAction
      Category = 'View'
      Caption = 'View / Edit Obj Info'
      Hint = 
        #1055#1086#1082#1072#1079#1072#1090#1100' ('#1080#1079#1084#1077#1085#1080#1090#1100') '#1089#1090#1088#1086#1082#1091' - '#1082#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081' '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1075#1086' '#1086#1073#1098#1077#1082#1090#1072' '#1076#1077#1088 +
        #1077#1074#1072
      ImageIndex = 30
      OnExecute = aViewEditObjInfoExecute
    end
    object aDebEditCompSPLText: TAction
      Category = 'Debug'
      Caption = 'Edit Component SPL Unit Text'
      ImageIndex = 29
      OnExecute = aDebEditCompSPLTextExecute
    end
    object aDebClearSelfRTI: TAction
      Category = 'Debug'
      Caption = 'Clear Self RTI'
      ImageIndex = 18
      OnExecute = aDebClearSelfRTIExecute
    end
    object aDebTmpAction1: TAction
      Category = 'Debug'
      Caption = 'Tmp Action 1'
      ImageIndex = 95
      OnExecute = aDebTmpAction1Execute
    end
    object aDebTmpAction2: TAction
      Category = 'Debug'
      Caption = 'Tmp Action 2'
      ImageIndex = 96
      OnExecute = aDebTmpAction2Execute
    end
    object aDebTmpAction3: TAction
      Category = 'Debug'
      Caption = 'Tmp Action 3'
      ImageIndex = 97
      OnExecute = aDebTmpAction3Execute
    end
    object aSESetCSAndCSCode: TAction
      Category = 'Special Edit'
      Caption = 'Set CS or CS Code(s)'
      Hint = #1055#1088#1080#1089#1074#1086#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1084#1091' '#1087#1086#1083#1102' '#1101#1083#1077#1084#1077#1085#1090' '#1082#1086#1076#1086#1074#1086#1075#1086' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072
      ImageIndex = 121
      OnExecute = aSESetCSAndCSCodeExecute
    end
    object aSESetUObj: TAction
      Category = 'Special Edit'
      Caption = 'Set UObj by Selected UObj'
      Hint = #1055#1088#1080#1089#1074#1086#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1086#1084#1091' '#1087#1086#1083#1102' '#1089#1089#1099#1083#1082#1091' '#1085#1072' '#1086#1073#1098#1077#1082#1090' '#1074' '#1076#1077#1088#1077#1074#1077
      ImageIndex = 122
      OnExecute = aSESetUObjExecute
    end
    object aEdCopySelected: TAction
      Category = 'Edit'
      Caption = 'Copy Selected To Clipboard'
      Hint = #1047#1072#1087#1086#1084#1085#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077' '#1087#1086#1083#1103' '#1074' '#1073#1091#1092#1077#1088#1077' '#1086#1073#1084#1077#1085#1072
      ImageIndex = 131
      OnExecute = aEdCopySelectedExecute
    end
    object aEdPasteInsteadOfSelected: TAction
      Category = 'Edit'
      Caption = 'Paste Instead Of Selected'
      Hint = #1042#1089#1090#1072#1074#1080#1090#1100' '#1079#1085#1072#1095#1077#1085#1080#1103' '#1080#1079' '#1073#1091#1092#1077#1088#1072' '#1086#1073#1084#1077#1085#1072' '#1085#1072' '#1084#1077#1089#1090#1086' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1093' '#1087#1086#1083#1077#1081
      ImageIndex = 132
      OnExecute = aEdPasteInsteadOfSelectedExecute
    end
    object aEdPasteInsideSelected: TAction
      Category = 'Edit'
      Caption = 'Paste Inside Selected'
      Hint = #1042#1089#1090#1072#1074#1080#1090#1100' '#1079#1085#1072#1095#1077#1085#1080#1103' '#1080#1079' '#1073#1091#1092#1077#1088#1072' '#1086#1073#1084#1077#1085#1072' '#1074#1085#1091#1090#1088#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1093' '#1087#1086#1083#1077#1081
      OnExecute = aEdPasteInsideSelectedExecute
    end
    object aEdPasteAndFillAllSelected: TAction
      Category = 'Edit'
      Caption = 'Paste And Fill Selected'
      OnExecute = aEdPasteAndFillAllSelectedExecute
    end
    object aEdClearSelected: TAction
      Category = 'Edit'
      Caption = 'Clear Selected Fields'
      Hint = #1054#1095#1080#1089#1090#1080#1090#1100' ('#1086#1073#1085#1091#1083#1080#1090#1100') '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077' '#1087#1086#1083#1103
      ImageIndex = 18
      OnExecute = aEdClearSelectedExecute
    end
    object aEdCreateNewRecords: TAction
      Category = 'Edit'
      Caption = 'Create New Records'
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1085#1086#1074#1099#1077' '#1079#1072#1087#1080#1089#1080
      ImageIndex = 124
      OnExecute = aEdCreateNewRecordsExecute
    end
    object aEdDestroySelectedRecords: TAction
      Category = 'Edit'
      Caption = 'Destroy Selected Records'
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1079#1072#1087#1080#1089#1080', '#1089#1086#1076#1077#1088#1078#1072#1097#1080#1077' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077' '#1087#1086#1083#1103
      ImageIndex = 133
      OnExecute = aEdDestroySelectedRecordsExecute
    end
    object aEdCreateSetParams: TAction
      Category = 'Edit'
      Caption = 'Create Component Settings'
      ImageIndex = 56
      OnExecute = aEdCreateSetParamsExecute
    end
    object aEdCreateExportParams: TAction
      Category = 'Edit'
      Caption = 'Create Component Export Params'
      ImageIndex = 127
      OnExecute = aEdCreateExportParamsExecute
    end
    object aEdCreateUserParams: TAction
      Category = 'Edit'
      Caption = 'Create Component User Params'
      ImageIndex = 89
      OnExecute = aEdCreateUserParamsExecute
    end
    object aEdCreatePanelParams: TAction
      Category = 'Edit'
      Caption = 'Create Component Panel Params'
      ImageIndex = 83
      OnExecute = aEdCreatePanelParamsExecute
    end
    object aIESetTableSize: TAction
      Category = 'IndEdit'
      Caption = 'Set Table Dimensions'
      ImageIndex = 128
      OnExecute = aIESetTableSizeExecute
    end
    object aIEView2DRArray: TAction
      Category = 'IndEdit'
      Caption = 'aIEView2DRArray'
      ImageIndex = 11
      OnExecute = aIEView2DRArrayExecute
    end
    object aSEImportUDTable: TAction
      Category = 'Special Edit'
      Caption = 'Import UDTable'
      ImageIndex = 4
      OnExecute = aSEImportUDTableExecute
    end
    object aSEExportUDTable: TAction
      Category = 'Special Edit'
      Caption = 'Export UDTable'
      ImageIndex = 5
      OnExecute = aSEExportUDTableExecute
    end
    object aAEEditAs1DRArray: TAction
      Category = 'Array Edit'
      Caption = 'Edit As 1D RArray'
      ImageIndex = 161
      OnExecute = aAEEditAs1DRArrayExecute
    end
    object aAEEditAs2DRArray: TAction
      Category = 'Array Edit'
      Caption = 'Edit As 2D RArray'
      ImageIndex = 173
      OnExecute = aAEEditAs2DRArrayExecute
    end
    object aViewObjHelp: TAction
      Category = 'View'
      Caption = 'View Object Help'
      ImageIndex = 7
      OnExecute = aViewObjHelpExecute
    end
  end
end
