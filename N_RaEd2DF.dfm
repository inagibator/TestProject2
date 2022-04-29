object N_RaEdit2DForm: TN_RaEdit2DForm
  Left = 103
  Top = 479
  Width = 312
  Height = 355
  Caption = 'N_RaEdit2DForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    304
    301)
  PixelsPerInch = 96
  TextHeight = 13
  object bnOK: TButton
    Left = 258
    Top = 259
    Width = 42
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = bnOKClick
  end
  object bnCancel: TButton
    Left = 214
    Top = 259
    Width = 42
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 1
    OnClick = bnCancelClick
  end
  object bnApply: TButton
    Left = 177
    Top = 259
    Width = 42
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = 'Apply'
    TabOrder = 2
    OnClick = bnApplyClick
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 304
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 3
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Caption = 'ToolButton1'
      ImageIndex = 0
    end
  end
  inline RAEditFrame: TK_FrameRAEdit
    Left = 0
    Top = 29
    Width = 304
    Height = 220
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
    TabOrder = 4
    inherited SGrid: TStringGrid
      Width = 304
      Height = 220
    end
    inherited BtExtEditor: TButton
      Left = 16
      Top = 120
    end
    inherited ActList: TActionList
      Left = 72
      Top = 112
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 282
    Width = 304
    Height = 19
    Panels = <>
  end
  object MainMenu1: TMainMenu
    Left = 184
    Top = 56
    object File1: TMenuItem
      Caption = 'File'
    end
  end
  object ActionList1: TActionList
    Left = 224
    Top = 56
  end
end
