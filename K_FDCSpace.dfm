inherited K_FormDCSpace: TK_FormDCSpace
  Left = 357
  Top = 143
  Width = 375
  Height = 481
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1082#1086#1076#1086#1074#1086#1075#1086' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072
  Menu = MainMenu
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    367
    427)
  PixelsPerInch = 96
  TextHeight = 13
  object LbName: TLabel [0]
    Left = 5
    Top = 32
    Width = 75
    Height = 13
    Caption = #1055#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086':'
  end
  object LbID: TLabel [1]
    Left = 2
    Top = 388
    Width = 14
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'ID:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 355
    Top = 415
    TabOrder = 7
  end
  object BtCancel: TButton
    Left = 248
    Top = 386
    Width = 56
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1082#1072#1079
    ModalResult = 2
    TabOrder = 0
    OnClick = BtCancelClick
  end
  object BtOK: TButton
    Left = 308
    Top = 386
    Width = 56
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 367
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Flat = True
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Action = CreateDCSpace
    end
    object ToolButton2: TToolButton
      Left = 25
      Top = 0
      Action = ImportDCSpace
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton3: TToolButton
      Left = 50
      Top = 0
      Action = ExportDCSpace
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton4: TToolButton
      Left = 75
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      Enabled = False
      ImageIndex = 3
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 83
      Top = 0
      Action = AddRow
      Grouped = True
    end
    object ToolButton14: TToolButton
      Left = 108
      Top = 0
      Action = K_FrameRAEdit.InsRow
    end
    object ToolButton8: TToolButton
      Left = 133
      Top = 0
      Action = K_FrameRAEdit.DelRow
    end
    object ToolButton15: TToolButton
      Left = 158
      Top = 0
      Width = 8
      Caption = 'ToolButton15'
      ImageIndex = 119
      Style = tbsSeparator
    end
    object ToolButton7: TToolButton
      Left = 166
      Top = 0
      Action = K_FrameRAEdit.CopyToClipBoard
    end
    object ToolButton6: TToolButton
      Left = 191
      Top = 0
      Action = K_FrameRAEdit.PasteFromClipBoard
    end
    object ToolButton12: TToolButton
      Left = 216
      Top = 0
      Action = K_FrameRAEdit.Search
    end
    object ToolButton13: TToolButton
      Left = 241
      Top = 0
      Action = EditAliases
    end
    object ToolButton9: TToolButton
      Left = 266
      Top = 0
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object ToolButton10: TToolButton
      Left = 274
      Top = 0
      Action = K_FrameRAEdit.RebuildGrid
    end
    object ToolButton11: TToolButton
      Left = 299
      Top = 0
      Action = K_FrameRAEdit.TranspGrid
    end
  end
  object CmBSList: TComboBox
    Left = 88
    Top = 29
    Width = 280
    Height = 21
    AutoComplete = False
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 3
    OnChange = CmBSListChange
    OnDropDown = CmBSListDropDown
    OnSelect = CmBSListSelect
  end
  object Button1: TButton
    Left = 159
    Top = 386
    Width = 75
    Height = 21
    Action = SaveCurDCSpace
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 4
  end
  inline K_FrameRAEdit: TK_FrameRAEdit
    Left = 0
    Top = 54
    Width = 367
    Height = 325
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    inherited SGrid: TStringGrid
      Width = 367
      Height = 325
    end
  end
  object EdID: TEdit
    Left = 19
    Top = 384
    Width = 127
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 6
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 408
    Width = 367
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object MainMenu: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 32
    Top = 400
    object MnSpace: TMenuItem
      Caption = #1060#1072#1081#1083
      object N3: TMenuItem
        Action = CreateDCSpace
      end
      object N4: TMenuItem
        Action = ImportDCSpace
      end
      object N5: TMenuItem
        Action = ExportDCSpace
      end
      object N9: TMenuItem
        Caption = #1059#1076#1072#1083#1080#1090#1100' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086
        Visible = False
      end
      object N14: TMenuItem
        Action = Close
      end
    end
    object MnEdit: TMenuItem
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      object N10: TMenuItem
        Action = K_FrameRAEdit.AddRow
      end
      object N13: TMenuItem
        Action = K_FrameRAEdit.DelRow
      end
      object N11: TMenuItem
        Action = K_FrameRAEdit.CopyToClipBoard
      end
      object N12: TMenuItem
        Action = K_FrameRAEdit.PasteFromClipBoard
      end
      object Search1: TMenuItem
        Action = K_FrameRAEdit.Search
      end
      object N1: TMenuItem
        Action = EditAliases
      end
      object N2: TMenuItem
        Action = RenameDCSpace
      end
    end
    object MnView: TMenuItem
      Caption = #1042#1080#1076
      object N16: TMenuItem
        Action = K_FrameRAEdit.RebuildGrid
      end
      object N17: TMenuItem
        Action = K_FrameRAEdit.TranspGrid
      end
    end
  end
  object ActionList: TActionList
    Images = N_ButtonsForm.ButtonsList
    Top = 400
    object SaveCurDCSpace: TAction
      Caption = #1047#1072#1087#1086#1084#1085#1080#1090#1100
      OnExecute = SaveCurDCSpaceExecute
    end
    object OpenDCSPace: TAction
      Caption = #1054#1090#1082#1088#1099#1090#1100
      OnExecute = OpenDCSPaceExecute
    end
    object CreateDCSpace: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086
      ImageIndex = 0
      OnExecute = CreateDCSpaceExecute
    end
    object ImportDCSpace: TAction
      Caption = #1048#1084#1087#1086#1088#1090' ...'
      Hint = #1048#1084#1087#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1077' '#1090#1077#1082#1091#1097#1077#1075#1086' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072' '#1080#1079' '#1074#1085#1077#1096#1085#1077#1075#1086' '#1092#1072#1081#1083#1072
      ImageIndex = 1
      OnExecute = ImportDCSpaceExecute
    end
    object ExportDCSpace: TAction
      Caption = #1069#1082#1089#1087#1086#1088#1090' ...'
      Hint = #1069#1082#1089#1087#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1077' '#1090#1077#1082#1091#1097#1077#1075#1086' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072' '#1074#1086' '#1074#1085#1077#1096#1085#1080#1081' '#1092#1072#1081#1083
      ImageIndex = 2
      OnExecute = ExportDCSpaceExecute
    end
    object EditAliases: TAction
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100' '#1085#1072#1079#1074#1072#1085#1080#1103' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' ...'
      Hint = #1048#1079#1084#1077#1085#1080#1090#1100' '#1090#1072#1073#1083#1080#1094#1091' '#1085#1072#1079#1074#1072#1085#1080#1081' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072
      ImageIndex = 29
      OnExecute = EditAliasesExecute
    end
    object Close: TAction
      Caption = #1042#1099#1093#1086#1076
      OnExecute = CloseExecute
    end
    object AddRow: TAction
      Caption = 'AddRow'
      ImageIndex = 69
      OnExecute = AddRowExecute
    end
    object RenameDCSpace: TAction
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' ...'
      OnExecute = RenameDCSpaceExecute
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 96
    Top = 400
  end
  object SaveDialog1: TSaveDialog
    Left = 128
    Top = 400
  end
end
