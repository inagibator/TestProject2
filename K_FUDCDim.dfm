inherited K_FormUDCDim: TK_FormUDCDim
  Left = 289
  Top = 136
  Width = 373
  Height = 497
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1082#1086#1076#1086#1074#1099#1093' '#1080#1079#1084#1077#1088#1077#1085#1080#1081
  Menu = MainMenu
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    365
    443)
  PixelsPerInch = 96
  TextHeight = 13
  object LbName: TLabel [0]
    Left = 5
    Top = 32
    Width = 64
    Height = 13
    Caption = #1048#1079#1084#1077#1088#1077#1085#1080#1077' :'
  end
  object LbID: TLabel [1]
    Left = 2
    Top = 384
    Width = 17
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'ID :'
  end
  inherited BFMinBRPanel: TPanel
    Left = 353
    Top = 431
    TabOrder = 6
  end
  object BtCancel: TButton
    Left = 246
    Top = 380
    Width = 56
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1082#1072#1079
    ModalResult = 2
    TabOrder = 0
    OnClick = BtCancelClick
  end
  object BtOK: TButton
    Left = 306
    Top = 380
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
    Width = 365
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Action = CreateCDim
    end
    object ToolButton4: TToolButton
      Left = 25
      Top = 2
      Width = 3
      Caption = 'ToolButton4'
      Enabled = False
      ImageIndex = 3
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 28
      Top = 2
      Action = K_FrameRAEdit.AddRow
      Grouped = True
    end
    object ToolButton14: TToolButton
      Left = 53
      Top = 2
      Action = K_FrameRAEdit.InsRow
    end
    object ToolButton8: TToolButton
      Left = 78
      Top = 2
      Action = K_FrameRAEdit.DelRow
    end
    object ToolButton2: TToolButton
      Left = 103
      Top = 2
      Width = 3
      Caption = 'ToolButton2'
      ImageIndex = 77
      Style = tbsSeparator
    end
    object ToolButton7: TToolButton
      Left = 106
      Top = 2
      Action = K_FrameRAEdit.CopyToClipBoard
    end
    object ToolButton6: TToolButton
      Left = 131
      Top = 2
      Action = K_FrameRAEdit.PasteFromClipBoard
    end
    object ToolButton12: TToolButton
      Left = 156
      Top = 2
      Action = K_FrameRAEdit.Search
    end
    object ToolButton9: TToolButton
      Left = 181
      Top = 2
      Width = 3
      Caption = 'ToolButton9'
      ImageIndex = 7
      Style = tbsSeparator
    end
    object ToolButton10: TToolButton
      Left = 184
      Top = 2
      Action = K_FrameRAEdit.RebuildGrid
    end
    object ToolButton11: TToolButton
      Left = 209
      Top = 2
      Action = K_FrameRAEdit.TranspGrid
    end
  end
  object Button1: TButton
    Left = 157
    Top = 380
    Width = 75
    Height = 21
    Action = ApplyCurCDim
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 3
  end
  inline K_FrameRAEdit: TK_FrameRAEdit
    Left = 0
    Top = 54
    Width = 365
    Height = 321
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
      Width = 365
      Height = 321
    end
    inherited ActList: TActionList
      inherited AddRow: TAction
        OnExecute = K_FrameRAEditAddRowExecute
      end
      inherited InsRow: TAction
        OnExecute = K_FrameRAEditInsRowExecute
      end
    end
  end
  object EdID: TEdit
    Left = 21
    Top = 380
    Width = 125
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 5
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 424
    Width = 365
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  inline FrameUDList: TK_FrameUDList
    Left = 72
    Top = 27
    Width = 293
    Height = 23
    TabOrder = 7
    inherited UDIcon: TImage
      Visible = True
    end
    inherited CmB: TComboBox
      Width = 247
    end
    inherited BtTreeSelect: TButton
      Left = 270
    end
  end
  object MainMenu: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 32
    Top = 400
    object MnSpace: TMenuItem
      Caption = #1054#1073#1098#1077#1082#1090
      object N3: TMenuItem
        Action = CreateCDim
      end
      object N5: TMenuItem
        Action = RenameCDim
      end
      object N9: TMenuItem
        Caption = #1059#1076#1072#1083#1080#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077
        Visible = False
      end
      object N14: TMenuItem
        Action = CloseAction
      end
    end
    object MnEdit: TMenuItem
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      object N10: TMenuItem
        Action = K_FrameRAEdit.AddRow
      end
      object N4: TMenuItem
        Action = K_FrameRAEdit.InsRow
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
      object MnSearch1: TMenuItem
        Action = K_FrameRAEdit.Search
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
    object ApplyCurCDim: TAction
      Caption = #1047#1072#1087#1086#1084#1085#1080#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
      Hint = #1047#1072#1087#1086#1084#1085#1080#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
      OnExecute = ApplyCurCDimExecute
    end
    object CreateCDim: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      ImageIndex = 0
      OnExecute = CreateCDimExecute
    end
    object CloseAction: TAction
      Caption = #1042#1099#1093#1086#1076
      OnExecute = CloseActionExecute
    end
    object RenameCDim: TAction
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      Hint = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      OnExecute = RenameCDimExecute
    end
  end
end
