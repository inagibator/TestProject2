inherited K_FormDCSProjection: TK_FormDCSProjection
  Left = 91
  Top = 286
  Width = 893
  Height = 515
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1087#1088#1086#1077#1082#1094#1080#1081' '#1082#1086#1076#1086#1074#1099#1093' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074
  Constraints.MaxWidth = 893
  Constraints.MinWidth = 812
  Menu = MainMenu1
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    885
    461)
  PixelsPerInch = 96
  TextHeight = 13
  object LbDestSpace: TLabel [0]
    Left = 336
    Top = 38
    Width = 175
    Height = 13
    Caption = #1055#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086' '#1087#1086#1083#1091#1095#1072#1090#1077#1083#1100' '#1076#1072#1085#1085#1099#1093':'
  end
  object LbSrcSpace: TLabel [1]
    Left = 4
    Top = 37
    Width = 164
    Height = 13
    Caption = #1055#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1086' '#1080#1089#1090#1086#1095#1085#1080#1082' '#1076#1072#1085#1085#1099#1093':'
  end
  object LbComment: TLabel [2]
    Left = 5
    Top = 414
    Width = 53
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077':'
  end
  object LbProj: TLabel [3]
    Left = 669
    Top = 38
    Width = 53
    Height = 13
    Caption = #1055#1088#1086#1077#1082#1094#1080#1080':'
  end
  object LbID: TLabel [4]
    Left = 44
    Top = 438
    Width = 14
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'ID:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 873
    Top = 449
    TabOrder = 13
  end
  object BBtnAdd: TBitBtn
    Left = 305
    Top = 59
    Width = 25
    Height = 25
    Action = AddItems
    Caption = '>>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object BtCancel: TButton
    Left = 760
    Top = 440
    Width = 57
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1082#1072#1079
    ModalResult = 2
    TabOrder = 1
    OnClick = BtCancelClick
  end
  object BtOK: TButton
    Left = 825
    Top = 440
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
    Top = 56
    Width = 300
    Height = 352
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
      Height = 352
    end
    inherited BtExtEditor_1: TButton
      Left = 136
      Top = 8
    end
  end
  inline K_FrameRAEditD: TK_FrameRAEdit
    Left = 335
    Top = 56
    Width = 550
    Height = 352
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
      Width = 550
      Height = 352
      OnClick = BBtnAddClick
    end
  end
  object EdComment: TEdit
    Left = 64
    Top = 411
    Width = 819
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 5
    OnChange = EdCommentChange
  end
  object CmBSListS: TComboBox
    Left = 173
    Top = 34
    Width = 127
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 6
    OnSelect = CmBSListSSelect
  end
  object CmBSListD: TComboBox
    Left = 532
    Top = 34
    Width = 127
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 7
    OnSelect = CmBSListDSelect
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 885
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Flat = True
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Action = CreateCurDCSProj
    end
    object ToolButton4: TToolButton
      Left = 25
      Top = 0
      Action = BuildByRProj
    end
    object ToolButton2: TToolButton
      Left = 50
      Top = 0
      Action = SaveCurDCSProj
      Visible = False
    end
    object ToolButton3: TToolButton
      Left = 75
      Top = 0
      Width = 3
      Caption = 'ToolButton3'
      ImageIndex = 15
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 78
      Top = 0
      Action = DeleteCurDCProj
      Visible = False
    end
  end
  object BBtnDel: TBitBtn
    Left = 305
    Top = 383
    Width = 25
    Height = 25
    Action = DelItems
    Anchors = [akRight, akBottom]
    Caption = 'X'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
  end
  object Button1: TButton
    Left = 653
    Top = 440
    Width = 75
    Height = 21
    Action = SaveCurDCSProj
    Anchors = [akRight, akBottom]
    TabOrder = 10
  end
  object CmBPList: TComboBox
    Left = 725
    Top = 34
    Width = 156
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 11
    OnSelect = CmBPListSelect
  end
  object EdID: TEdit
    Left = 63
    Top = 434
    Width = 269
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 12
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 848
    object CreateCurDCSProj: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1087#1088#1086#1077#1082#1094#1080#1102
      ImageIndex = 0
      OnExecute = CreateCurDCSProjExecute
    end
    object SaveCurDCSProj: TAction
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ImageIndex = 3
      OnExecute = SaveCurDCSProjExecute
    end
    object DeleteCurDCProj: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100
      ImageIndex = 16
    end
    object BuildByRProj: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1080#1079' '#1086#1073#1088#1072#1090#1085#1086#1081' '#1087#1088#1086#1077#1082#1094#1080#1080
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1087#1088#1086#1077#1082#1094#1080#1102' '#1080#1079' '#1086#1073#1088#1072#1090#1085#1086#1081' '#1087#1088#1086#1077#1082#1094#1080#1080
      ImageIndex = 4
      OnExecute = BuildByRProjExecute
    end
    object CLose: TAction
      Caption = #1042#1099#1093#1086#1076
      OnExecute = CLoseExecute
    end
    object AddItems: TAction
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1101#1083#1077#1084#1077#1085#1090#1099
      Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077' '#1101#1083#1077#1084#1077#1085#1090#1099' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072' '#1080#1089#1090#1086#1095#1085#1080#1082#1072
      OnExecute = AddItemsExecute
    end
    object DelItems: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077
      Hint = #1059#1076#1072#1083#1080#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1085#1099#1077' '#1101#1083#1077#1084#1077#1085#1090#1099' '#1087#1088#1086#1089#1090#1088#1072#1085#1089#1090#1074#1072' '#1087#1086#1083#1091#1095#1072#1090#1077#1083#1103
      OnExecute = DelItemsExecute
    end
    object RenameDCSProj: TAction
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' ...'
      OnExecute = RenameDCSProjExecute
    end
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 817
    Top = 3
    object N1: TMenuItem
      Caption = #1055#1088#1086#1077#1082#1094#1080#1103
      object N2: TMenuItem
        Action = CreateCurDCSProj
      end
      object N3: TMenuItem
        Action = BuildByRProj
      end
      object N4: TMenuItem
        Action = CLose
      end
    end
    object N5: TMenuItem
      Caption = #1055#1088#1072#1074#1082#1072
      object N6: TMenuItem
        Action = AddItems
      end
      object N7: TMenuItem
        Action = DelItems
      end
      object N8: TMenuItem
        Action = RenameDCSProj
      end
    end
  end
end
