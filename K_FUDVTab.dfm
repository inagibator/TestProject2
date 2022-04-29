inherited K_FormUDVectorsTab: TK_FormUDVectorsTab
  Left = 335
  Top = 272
  Width = 176
  Height = 192
  Caption = 'K_FormUDVectorsTab'
  Menu = MainMenu1
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    168
    138)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 156
    Top = 126
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 119
    Width = 168
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 78
    Height = 29
    Align = alNone
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Action = TabDataFrame.AddCol
    end
    object ToolButton2: TToolButton
      Left = 25
      Top = 2
      Action = TabDataFrame.DelCol
    end
    object ToolButton3: TToolButton
      Left = 50
      Top = 2
      Action = TabDataFrame.RebuildGrid
    end
  end
  object EdiColName: TEdit
    Left = 80
    Top = 3
    Width = 86
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    OnKeyDown = EdiColNameKeyDown
  end
  object BtOK: TButton
    Left = 91
    Top = 98
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
    OnClick = BtOKClick
  end
  object BtCancel: TButton
    Left = 4
    Top = 98
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1082#1072#1079
    ModalResult = 2
    TabOrder = 4
    OnClick = BtCancelClick
  end
  inline TabDataFrame: TK_FrameRATabEdit
    Left = 0
    Top = 26
    Width = 168
    Height = 70
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
      Width = 168
      Height = 70
    end
  end
  object MainMenu1: TMainMenu
    Left = 91
    object N1: TMenuItem
      Caption = #1058#1072#1073#1083#1080#1094#1072
    end
    object N3: TMenuItem
      Caption = #1055#1088#1072#1074#1082#1072
      object AddCol1: TMenuItem
        Action = TabDataFrame.AddCol
      end
      object DeleteCol1: TMenuItem
        Action = TabDataFrame.DelCol
      end
    end
    object N2: TMenuItem
      Caption = #1042#1080#1076
      object RebuildGrid1: TMenuItem
        Action = TabDataFrame.RebuildGrid
      end
    end
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 122
  end
end
