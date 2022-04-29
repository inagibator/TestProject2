inherited K_FormCMImportPPL: TK_FormCMImportPPL
  Left = 290
  Top = 523
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Import Data'
  ClientHeight = 214
  ClientWidth = 540
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 40
    Top = 184
    Width = 217
    Height = 13
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 530
    Top = 204
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 461
    Top = 181
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Exit'
    ModalResult = 2
    TabOrder = 0
  end
  object BtStart: TButton
    Left = 392
    Top = 181
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Start'
    TabOrder = 1
    OnClick = BtStartClick
  end
  object SGStateView: TStringGrid
    Left = 16
    Top = 62
    Width = 509
    Height = 103
    Anchors = [akLeft, akTop, akRight]
    DefaultColWidth = 100
    RowCount = 4
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    TabOrder = 3
    OnDrawCell = SGStateViewDrawCell
    OnExit = SGStateViewExit
  end
  inline FileNameFrame: TN_FileNameFrame
    Tag = 161
    Left = 14
    Top = 16
    Width = 509
    Height = 27
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 4
    inherited Label1: TLabel
      Left = 0
      Width = 47
      Caption = 'XML File :'
    end
    inherited mbFileName: TComboBox
      Left = 56
      Width = 419
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 485
    end
    inherited OpenPictureDialog: TOpenPictureDialog
      Top = 65528
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = TimerTimer
    Left = 352
    Top = 176
  end
end
