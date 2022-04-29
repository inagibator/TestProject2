inherited K_FormCMFSACopy: TK_FormCMFSACopy
  Left = 172
  Top = 472
  Width = 457
  Height = 308
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Additional Files Copy'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel [0]
    Left = 8
    Top = 204
    Width = 425
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 428
    Top = 258
  end
  object BtClose: TButton
    Left = 356
    Top = 234
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 1
  end
  object BtStart: TButton
    Left = 270
    Top = 234
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Start'
    TabOrder = 2
    OnClick = BtStartClick
  end
  inline SSPNFrame: TK_FPathNameFrame
    Tag = 161
    Left = 4
    Top = 8
    Width = 436
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    inherited LbPathName: TLabel
      Left = 17
      Width = 104
      Caption = 'Source segment path:'
    end
    inherited mbPathName: TComboBox
      Left = 136
      Width = 269
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 407
      Top = 2
    end
  end
  object GBArchiving: TGroupBox
    Left = 4
    Top = 124
    Width = 436
    Height = 77
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Copying progress  '
    TabOrder = 4
    DesignSize = (
      436
      77)
    object LbEDProcCount: TLabeledEdit
      Left = 118
      Top = 20
      Width = 310
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 98
      EditLabel.Height = 13
      EditLabel.Caption = 'Processed files:        '
      EditLabel.Layout = tlCenter
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
      Text = '0'
    end
    object PBProgress: TProgressBar
      Left = 10
      Top = 50
      Width = 417
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Smooth = True
      TabOrder = 1
    end
  end
  inline DSPNFrame: TK_FPathNameFrame
    Tag = 161
    Left = 4
    Top = 48
    Width = 436
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    inherited LbPathName: TLabel
      Left = 20
      Width = 101
      Caption = 'Target segment path:'
    end
    inherited mbPathName: TComboBox
      Left = 136
      Width = 268
      Color = 10682367
    end
    inherited bnBrowse_1: TButton
      Left = 407
    end
  end
  inline CLFNFrame: TN_FileNameFrame
    Tag = 161
    Left = 14
    Top = 88
    Width = 425
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = CLFNFrame.FilePopupMenu
    TabOrder = 6
    inherited Label1: TLabel
      Width = 90
      Caption = 'Copy list file name :'
    end
    inherited mbFileName: TComboBox
      Left = 96
      Width = 295
    end
    inherited bnBrowse_1: TButton
      Left = 397
      Top = 2
    end
    inherited OpenDialog: TOpenDialog
      Left = 189
    end
  end
end
