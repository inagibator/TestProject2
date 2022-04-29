inherited K_FormDCSSpace: TK_FormDCSSpace
  Left = 215
  Top = 240
  Width = 644
  Height = 558
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1087#1086#1076#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072
  Constraints.MaxWidth = 644
  Constraints.MinWidth = 644
  Menu = MainMenu1
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    636
    504)
  PixelsPerInch = 96
  TextHeight = 13
  object LbSSpace: TLabel [0]
    Left = 336
    Top = 35
    Width = 93
    Height = 13
    Caption = #1055#1086#1076#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086':'
  end
  object LbSpace: TLabel [1]
    Left = 4
    Top = 35
    Width = 75
    Height = 13
    Caption = #1055#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086':'
  end
  object LbID: TLabel [2]
    Left = 4
    Top = 479
    Width = 14
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'ID:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 624
    Top = 492
    TabOrder = 11
  end
  object BBtnAdd: TBitBtn
    Left = 305
    Top = 56
    Width = 25
    Height = 25
    Action = AddSSItems
    Caption = '>>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object BtCancel: TButton
    Left = 510
    Top = 479
    Width = 57
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1082#1072#1079
    ModalResult = 2
    TabOrder = 1
    OnClick = BtCancelClick
  end
  object BtOK: TButton
    Left = 577
    Top = 479
    Width = 57
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    ModalResult = 1
    TabOrder = 2
    OnClick = BtOKClick
  end
  inline K_FrameRAEditS: TK_FrameRAEdit
    Left = 0
    Top = 57
    Width = 300
    Height = 409
    Anchors = [akLeft, akTop, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    inherited SGrid: TStringGrid
      Width = 300
      Height = 409
    end
    inherited BtExtEditor_1: TButton
      Left = 32
      Top = 4
    end
  end
  inline K_FrameRAEditSS: TK_FrameRAEdit
    Left = 335
    Top = 56
    Width = 300
    Height = 410
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    inherited SGrid: TStringGrid
      Width = 300
      Height = 410
    end
  end
  object CmBSList: TComboBox
    Left = 86
    Top = 32
    Width = 215
    Height = 21
    AutoDropDown = True
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 5
    OnSelect = CmBSListSelect
  end
  object CmBSSList: TComboBox
    Left = 437
    Top = 32
    Width = 199
    Height = 21
    AutoComplete = False
    AutoDropDown = True
    ItemHeight = 13
    TabOrder = 6
    OnChange = CmBSSListChange
    OnDropDown = CmBSSListDropDown
    OnSelect = CmBSSListSelect
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 636
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Flat = True
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    object ToolButton2: TToolButton
      Left = 0
      Top = 0
      Action = CreateDCSSpace
    end
    object ToolButton1: TToolButton
      Left = 25
      Top = 0
      Action = ImportCurDCSSpace
    end
    object ToolButton3: TToolButton
      Left = 50
      Top = 0
      Action = ExportCurDCSSpace
    end
    object ToolButton4: TToolButton
      Left = 75
      Top = 0
      Width = 3
      Caption = 'ToolButton4'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 78
      Top = 0
      Action = ReLinkCSSData
    end
  end
  object Button1: TButton
    Left = 381
    Top = 479
    Width = 75
    Height = 21
    Action = SaveCurDCSSpace
    Anchors = [akRight, akBottom]
    TabOrder = 8
  end
  object BBtnDel: TButton
    Left = 306
    Top = 440
    Width = 25
    Height = 25
    Action = K_FrameRAEditSS.DelRow
    Anchors = [akLeft, akBottom]
    Caption = 'X'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
  end
  object EdID: TEdit
    Left = 21
    Top = 475
    Width = 188
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 10
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 608
    object CreateDCSSpace: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1087#1086#1076#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086
      ImageIndex = 0
      OnExecute = CreateDCSSpaceExecute
    end
    object OpenDCSSpace: TAction
      Caption = 'OpenDCSSpace'
      OnExecute = OpenDCSSpaceExecute
    end
    object SaveCurDCSSpace: TAction
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      OnExecute = SaveCurDCSSpaceExecute
    end
    object ImportCurDCSSpace: TAction
      Caption = #1048#1084#1087#1086#1088#1090' ...'
      Hint = 
        #1048#1084#1087#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1077' '#1090#1077#1082#1091#1097#1077#1075#1086' '#1087#1086#1076#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072' '#1080#1079' '#1074#1085#1077#1096#1085#1077#1075#1086' '#1092#1072 +
        #1081#1083#1072
      ImageIndex = 1
      OnExecute = ImportCurDCSSpaceExecute
    end
    object ExportCurDCSSpace: TAction
      Caption = #1069#1082#1089#1087#1086#1088#1090' ...'
      Hint = 
        #1069#1082#1089#1087#1086#1088#1090#1080#1088#1086#1074#1072#1090#1100' '#1089#1086#1076#1077#1088#1078#1080#1084#1086#1077' '#1090#1077#1082#1091#1097#1077#1075#1086' '#1087#1086#1076#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072' '#1074#1086' '#1074#1085#1077#1096#1085#1080#1081' '#1092#1072 +
        #1081#1083
      ImageIndex = 2
      OnExecute = ExportCurDCSSpaceExecute
    end
    object Close: TAction
      Caption = #1042#1099#1093#1086#1076
      OnExecute = CloseExecute
    end
    object AddSSItems: TAction
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1101#1083#1077#1084#1077#1085#1090#1099
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077' '#1101#1083#1077#1084#1077#1085#1090#1099' '#1087#1088#1086#1089#1090#1088#1072#1089#1090#1074#1072' '#1074' '#1087#1086#1076#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086
      OnExecute = AddSSItemsExecute
    end
    object RenameDCSSpace: TAction
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' ...'
      OnExecute = RenameDCSSpaceExecute
    end
    object ReLinkCSSData: TAction
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100' '#1087#1086#1076#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086' '#1074#1086' '#1074#1089#1077#1093' '#1089#1074#1103#1079#1072#1085#1085#1099#1093' '#1074#1077#1082#1090#1086#1088#1072#1093
      ImageIndex = 92
      OnExecute = ReLinkCSSDataExecute
    end
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 576
    object N1: TMenuItem
      Caption = #1055#1086#1076#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086
      object N2: TMenuItem
        Action = CreateDCSSpace
      end
      object N3: TMenuItem
        Action = ImportCurDCSSpace
      end
      object N4: TMenuItem
        Action = ExportCurDCSSpace
      end
      object N5: TMenuItem
        Action = Close
      end
    end
    object N6: TMenuItem
      Caption = #1055#1088#1072#1074#1082#1072
      object N7: TMenuItem
        Action = AddSSItems
      end
      object N8: TMenuItem
        Action = K_FrameRAEditSS.DelRow
      end
      object N9: TMenuItem
        Action = RenameDCSSpace
      end
      object N10: TMenuItem
        Action = ReLinkCSSData
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 512
  end
  object SaveDialog1: TSaveDialog
    Left = 480
  end
end
