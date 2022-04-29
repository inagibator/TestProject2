inherited K_FormUDCDCor: TK_FormUDCDCor
  Left = 164
  Top = 341
  Width = 956
  Height = 517
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1086#1090#1085#1086#1096#1077#1085#1080#1081' '#1082#1086#1076#1086#1074#1099#1093' '#1080#1079#1084#1077#1088#1077#1085#1080#1081
  Constraints.MaxWidth = 956
  Constraints.MinWidth = 956
  Menu = MainMenu1
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    948
    463)
  PixelsPerInch = 96
  TextHeight = 13
  object LbID: TLabel [0]
    Left = 5
    Top = 441
    Width = 18
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'ID:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel [1]
    Left = 120
    Top = 8
    Width = 120
    Height = 13
    Caption = #1057#1074#1103#1079#1072#1085#1085#1086#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' :'
  end
  object Label6: TLabel [2]
    Left = 540
    Top = 8
    Width = 115
    Height = 13
    Caption = #1054#1089#1085#1086#1074#1085#1086#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' :'
  end
  object Label7: TLabel [3]
    Left = 246
    Top = 441
    Width = 63
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1085#1086#1096#1077#1085#1080#1077' :'
  end
  inherited BFMinBRPanel: TPanel
    Left = 936
    Top = 451
    TabOrder = 9
  end
  object BtCancel: TButton
    Left = 823
    Top = 437
    Width = 57
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1082#1072#1079
    ModalResult = 2
    TabOrder = 0
    OnClick = BtCancelClick
  end
  object BtOK: TButton
    Left = 888
    Top = 437
    Width = 57
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
    Width = 113
    Height = 29
    Align = alNone
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
      Action = CreateUDCDCor
    end
    object ToolButton3: TToolButton
      Left = 25
      Top = 2
      Width = 3
      Caption = 'ToolButton3'
      ImageIndex = 15
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 28
      Top = 2
      Action = ChangePrimCSDim
    end
    object ToolButton2: TToolButton
      Left = 53
      Top = 2
      Action = ReplaceSecCDim
    end
    object ToolButton6: TToolButton
      Left = 78
      Top = 2
      Width = 3
      Caption = 'ToolButton6'
      ImageIndex = 188
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 81
      Top = 2
      Action = RebuildAllFrames
    end
  end
  object Button1: TButton
    Left = 721
    Top = 437
    Width = 75
    Height = 21
    Action = ApplyUDCDCor
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  object EdID: TEdit
    Left = 26
    Top = 437
    Width = 207
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 4
  end
  object Panel1: TPanel
    Left = -1
    Top = 30
    Width = 949
    Height = 400
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 5
    DesignSize = (
      949
      400)
    object Label3: TLabel
      Left = 48
      Top = 15
      Width = 228
      Height = 13
      Caption = #1042#1089#1077' '#1101#1083#1077#1084#1077#1085#1090#1099' '#1089#1074#1103#1079#1072#1085#1085#1086#1075#1086' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 456
      Top = 21
      Width = 114
      Height = 13
      Caption = #1057#1074#1103#1079#1072#1085#1085#1086#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1077
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 736
      Top = 21
      Width = 109
      Height = 13
      Caption = #1054#1089#1085#1086#1074#1085#1086#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1077
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 584
      Top = 8
      Width = 129
      Height = 13
      Caption = #1069#1083#1077#1084#1077#1085#1090#1099' '#1086#1090#1085#1086#1096#1077#1085#1080#1103
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    inline FrameCDCor: TK_FrameCDCor
      Left = 1
      Top = 40
      Width = 947
      Height = 359
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      inherited K_FrameRAEditSec: TK_FrameRAEdit
        Height = 360
        inherited SGrid: TStringGrid
          Height = 360
        end
      end
      inherited K_FrameRAEditPrim: TK_FrameRAEdit
        Width = 611
        Height = 361
        inherited SGrid: TStringGrid
          Width = 611
          Height = 361
        end
      end
    end
  end
  inline FUDList: TK_FrameUDList
    Left = 312
    Top = 436
    Width = 392
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 6
    inherited UDIcon: TImage
      Visible = True
    end
    inherited CmB: TComboBox
      Width = 346
    end
    inherited BtTreeSelect: TButton
      Left = 369
    end
  end
  object EdPrimCDimName: TEdit
    Left = 660
    Top = 5
    Width = 288
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 7
  end
  object EdSecCDimName: TEdit
    Left = 243
    Top = 5
    Width = 281
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 8
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 912
    object CreateUDCDCor: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1086#1073#1098#1077#1082#1090' ...'
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077
      ImageIndex = 0
      OnExecute = CreateUDCDCorExecute
    end
    object ApplyUDCDCor: TAction
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      Hint = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1086#1089#1090#1086#1103#1085#1080#1077' '#1074' '#1086#1073#1098#1077#1082#1090#1077
      ImageIndex = 3
      OnExecute = ApplyUDCDCorExecute
    end
    object DeleteUDCDCor: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100
      ImageIndex = 16
    end
    object CLoseAction: TAction
      Caption = #1042#1099#1093#1086#1076
      OnExecute = CLoseActionExecute
    end
    object RenameUDCDCor: TAction
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1086#1073#1098#1077#1082#1090' ...'
      OnExecute = RenameUDCDCorExecute
    end
    object ChangePrimCSDim: TAction
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100' '#1085#1072#1073#1086#1088' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1086#1089#1085#1086#1074#1085#1086#1075#1086' '#1080#1079#1084#1077#1088#1077#1085#1103' ...'
      Hint = #1048#1079#1084#1077#1085#1080#1090#1100' '#1085#1072#1073#1086#1088' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1086#1089#1085#1086#1074#1085#1086#1075#1086' '#1080#1079#1084#1077#1088#1077#1085#1103
      ImageIndex = 185
      OnExecute = ChangePrimCSDimExecute
    end
    object ReplaceSecCDim: TAction
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100' '#1089#1074#1103#1079#1072#1085#1085#1086#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      Hint = #1048#1079#1084#1077#1085#1080#1090#1100' '#1089#1074#1103#1079#1072#1085#1085#1086#1077' '#1080#1079#1084#1077#1088#1077#1085#1080#1077' ...'
      ImageIndex = 186
      OnExecute = ReplaceSecCDimExecute
    end
    object RebuildAllFrames: TAction
      Caption = #1055#1077#1088#1077#1089#1090#1088#1086#1080#1090#1100' '#1074#1080#1076
      Hint = #1055#1077#1088#1077#1089#1090#1088#1086#1080#1090#1100' '#1074#1080#1076
      ImageIndex = 75
      OnExecute = RebuildAllFramesExecute
    end
  end
  object MainMenu1: TMainMenu
    Left = 880
    object N1: TMenuItem
      Caption = #1054#1073#1098#1077#1082#1090
      object N2: TMenuItem
        Action = CreateUDCDCor
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' ...'
        Hint = #1057#1086#1079#1076#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' ...'
      end
      object N5: TMenuItem
        Action = FUDList.SelectUDObj
        Caption = #1042#1099#1073#1088#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' ...'
        Hint = #1042#1099#1073#1088#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' ...'
      end
      object N3: TMenuItem
        Action = RenameUDCDCor
        Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' ...'
        Hint = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1086#1090#1085#1086#1096#1077#1085#1080#1077' ...'
      end
      object N4: TMenuItem
        Action = CLoseAction
      end
    end
  end
end
