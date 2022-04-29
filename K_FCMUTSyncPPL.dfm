inherited K_FormCMUTSyncPPL: TK_FormCMUTSyncPPL
  Left = 63
  Top = 464
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Link Patients  IDs'
  ClientHeight = 244
  ClientWidth = 545
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 16
    Top = 218
    Width = 314
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 535
    Top = 234
    TabOrder = 1
  end
  object BtCancel: TButton
    Left = 466
    Top = 211
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Exit'
    ModalResult = 2
    TabOrder = 0
  end
  inline PathNameFrame: TK_FPathNameFrame
    Tag = 161
    Left = 16
    Top = 36
    Width = 515
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    inherited LbPathName: TLabel
      Left = 0
      Width = 127
      Alignment = taLeftJustify
      Caption = 'Media files resulting folder :'
    end
    inherited mbPathName: TComboBox
      Left = 136
      Width = 347
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 491
      Top = 2
      Width = 22
    end
  end
  object BtSync: TButton
    Left = 345
    Top = 211
    Width = 115
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Link'
    TabOrder = 3
    OnClick = BtSyncClick
  end
  object SGStateView: TStringGrid
    Left = 16
    Top = 72
    Width = 513
    Height = 128
    Anchors = [akLeft, akTop, akRight]
    ColCount = 3
    DefaultColWidth = 166
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    TabOrder = 4
    OnDrawCell = SGStateViewDrawCell
    OnExit = SGStateViewExit
  end
  inline FileNameFrame: TN_FileNameFrame
    Tag = 161
    Left = 16
    Top = 8
    Width = 512
    Height = 27
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 5
    inherited Label1: TLabel
      Left = -1
      Width = 77
      Caption = 'Link info (*.xml) :'
    end
    inherited mbFileName: TComboBox
      Left = 136
      Width = 344
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 488
    end
    inherited OpenDialog: TOpenDialog
      Left = 189
    end
    inherited OpenPictureDialog: TOpenPictureDialog
      Left = 218
    end
    inherited FilePopupMenu: TPopupMenu
      Left = 249
    end
    inherited FNameActList: TActionList
      Left = 278
    end
  end
end
