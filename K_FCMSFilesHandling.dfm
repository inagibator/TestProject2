inherited K_FormCMSFilesHandling: TK_FormCMSFilesHandling
  Left = 223
  Top = 139
  Width = 424
  Height = 524
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Image and Video Files Handling'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 404
    Top = 478
    TabOrder = 2
  end
  object BtClose: TButton
    Left = 253
    Top = 458
    Width = 74
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 0
  end
  object BtCancel: TButton
    Left = 333
    Top = 458
    Width = 74
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object GBImgLocation: TGroupBox
    Left = 8
    Top = 8
    Width = 399
    Height = 80
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Image Files  '
    TabOrder = 3
    DesignSize = (
      399
      80)
    object LEdImgFPath: TLabeledEdit
      Left = 48
      Top = 16
      Width = 335
      Height = 21
      Hint = 'Image files folder'
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = 'Path:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
    end
    object BtChangeImgServer: TButton
      Left = 256
      Top = 46
      Width = 126
      Height = 23
      Hint = 'Change image files folder'
      Action = ChangeImgRoot
      Anchors = [akRight, akBottom]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object ChBServerMigration: TCheckBox
      Left = 16
      Top = 48
      Width = 233
      Height = 17
      Hint = 'Automatically change Video and 3D Image file folders'
      Caption = 'Server migration'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = ChBServerMigrationClick
    end
  end
  object GBVideoLocation: TGroupBox
    Left = 8
    Top = 96
    Width = 399
    Height = 80
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Video Files  '
    TabOrder = 4
    DesignSize = (
      399
      80)
    object LEdServMediaFPath: TLabeledEdit
      Left = 48
      Top = 16
      Width = 335
      Height = 21
      Hint = 'Video files folder'
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = 'Path:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
    end
    object BtChangeMediaServer: TButton
      Left = 256
      Top = 46
      Width = 126
      Height = 23
      Hint = 'Change video files folder'
      Action = ChangeMediaServRoot
      Anchors = [akRight, akBottom]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object GBScanLocation: TGroupBox
    Left = 8
    Top = 272
    Width = 399
    Height = 179
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Client Capture Files  '
    TabOrder = 5
    DesignSize = (
      399
      179)
    object LEdScanDataPath: TLabeledEdit
      Left = 48
      Top = 16
      Width = 335
      Height = 21
      Hint = 'Current path to exchange folder'
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = 'Path:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = LEdScanDataPathChange
    end
    object BtChangeScanDataPath: TButton
      Left = 256
      Top = 46
      Width = 126
      Height = 23
      Hint = 'Change current path to exchange folder'
      Anchors = [akTop, akRight]
      Caption = 'Change Folder'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = BtChangeScanDataPathClick
    end
    object LEdScanDataPathOld: TLabeledEdit
      Left = 63
      Top = 146
      Width = 319
      Height = 21
      Hint = 
        'Previous path to exchange folder (indicates that some clients us' +
        'e old path)'
      Anchors = [akLeft, akRight, akBottom]
      Color = clBtnFace
      EditLabel.Width = 48
      EditLabel.Height = 13
      EditLabel.Caption = 'Path old:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 2
    end
    object ChBCMScanAutoChange: TCheckBox
      Left = 12
      Top = 50
      Width = 233
      Height = 17
      Caption = 'Data exchange folder near server file storage'
      TabOrder = 3
      OnClick = ChBCMScanAutoChangeClick
    end
    object ChBCMScanClient: TCheckBox
      Left = 12
      Top = 74
      Width = 233
      Height = 17
      Caption = 'Data exchange folder on the Client PC'
      TabOrder = 4
      OnClick = ChBCMScanClientClick
    end
    object ChBCMScanClientAuto: TCheckBox
      Left = 12
      Top = 98
      Width = 233
      Height = 17
      Caption = 'Client PC Exchange folder Auto detect'
      TabOrder = 5
      OnClick = ChBCMScanClientAutoClick
    end
    object ChBCMScanClientRedirect: TCheckBox
      Left = 12
      Top = 122
      Width = 317
      Height = 17
      Caption = 'Automatically update the Exchange folder path for all clients'
      TabOrder = 6
      OnClick = ChBCMScanClientAutoClick
    end
  end
  object GBImg3DLocation: TGroupBox
    Left = 8
    Top = 184
    Width = 399
    Height = 80
    Anchors = [akLeft, akTop, akRight]
    Caption = '  3D Image Files  '
    TabOrder = 6
    DesignSize = (
      399
      80)
    object LEdImg3DFPath: TLabeledEdit
      Left = 48
      Top = 16
      Width = 335
      Height = 21
      Hint = '3D image files folder'
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = 'Path:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
    end
    object BtChangeImg3DServer: TButton
      Left = 256
      Top = 46
      Width = 126
      Height = 23
      Hint = 'Change 3D image files folder'
      Action = ChangeImg3DRoot
      Anchors = [akRight, akBottom]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object ActionList1: TActionList
    Left = 24
    Top = 456
    object ChangeImgRoot: TAction
      Caption = 'Change Folder'
      Hint = 'Change image files folder on server computer'
      OnExecute = ChangeImgRootExecute
    end
    object ChangeMediaServRoot: TAction
      Caption = 'Change Folder'
      Hint = 'Change video files folder on server computer'
      OnExecute = ChangeMediaServRootExecute
    end
    object ChangeImg3DRoot: TAction
      Caption = 'Change Folder'
      OnExecute = ChangeImg3DRootExecute
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 64
    Top = 456
  end
end
