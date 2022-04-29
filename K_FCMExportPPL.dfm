inherited K_FormCMExportPPL: TK_FormCMExportPPL
  Left = 210
  Top = 448
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Export Data'
  ClientHeight = 214
  ClientWidth = 542
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 16
    Top = 184
    Width = 241
    Height = 13
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 532
    Top = 204
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 463
    Top = 181
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Exit'
    ModalResult = 2
    TabOrder = 0
  end
  object BtStart: TButton
    Left = 394
    Top = 181
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Start'
    TabOrder = 1
    OnClick = BtStartClick
  end
  inline PathNameFrame: TK_FPathNameFrame
    Tag = 161
    Left = 15
    Top = 16
    Width = 512
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    inherited LbPathName: TLabel
      Left = 0
      Width = 57
      Alignment = taLeftJustify
      Caption = 'XML folder :'
    end
    inherited mbPathName: TComboBox
      Left = 88
      Width = 392
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 488
      Top = 2
      Width = 22
    end
  end
  object BtSync: TButton
    Left = 272
    Top = 181
    Width = 115
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'S&ynchronize'
    TabOrder = 4
    OnClick = BtSyncClick
  end
  object SGStateView: TStringGrid
    Left = 16
    Top = 62
    Width = 508
    Height = 103
    Anchors = [akLeft, akTop, akRight]
    DefaultColWidth = 100
    RowCount = 4
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    TabOrder = 5
    OnDrawCell = SGStateViewDrawCell
    OnExit = SGStateViewExit
  end
  object Timer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = TimerTimer
    Left = 216
    Top = 176
  end
end
