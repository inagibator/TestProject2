inherited K_FormCMSFilesHandlingE: TK_FormCMSFilesHandlingE
  Left = 433
  Top = 115
  Width = 430
  Height = 612
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Image and Video Files Handling'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 7
    Top = 201
    Width = 407
    Height = 1
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object Bevel2: TBevel [1]
    Left = 7
    Top = 35
    Width = 407
    Height = 1
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  inherited BFMinBRPanel: TPanel
    Left = 412
    Top = 568
    TabOrder = 3
  end
  object BtClose: TButton
    Left = 259
    Top = 546
    Width = 74
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 0
  end
  object BtCancel: TButton
    Left = 339
    Top = 546
    Width = 74
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object ChBHeadLocationFlag: TCheckBox
    Left = 12
    Top = 11
    Width = 397
    Height = 17
    Hint = 
      'Notify application that current location is the Central file sto' +
      'rage'
    Caption = 'This location is the Central file storage'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  object GBImgLocation: TGroupBox
    Left = 8
    Top = 32
    Width = 400
    Height = 112
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Image Files  '
    TabOrder = 4
    DesignSize = (
      400
      112)
    object LEdImgFPath: TLabeledEdit
      Left = 88
      Top = 16
      Width = 296
      Height = 21
      Hint = 'Image files folder Internal Path'
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      EditLabel.Width = 68
      EditLabel.Height = 13
      EditLabel.Caption = 'Internal path:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
    end
    object BtChangeImgServer: TButton
      Left = 257
      Top = 48
      Width = 126
      Height = 23
      Hint = 'Change image files folder'
      Action = ChangeImgRoot
      Anchors = [akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object LEdImgEFPath: TLabeledEdit
      Left = 88
      Top = 80
      Width = 296
      Height = 21
      Hint = 'Image files folder External Path'
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 71
      EditLabel.Height = 13
      EditLabel.Caption = 'External path:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
  end
  object GBServerMediaLocation: TGroupBox
    Left = 8
    Top = 152
    Width = 400
    Height = 112
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Video Files  '
    TabOrder = 5
    DesignSize = (
      400
      112)
    object LEdServMediaFPath: TLabeledEdit
      Left = 88
      Top = 16
      Width = 296
      Height = 21
      Hint = 'Video files folder Internal Path'
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      EditLabel.Width = 69
      EditLabel.Height = 13
      EditLabel.Caption = 'Internal Path:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 0
    end
    object BtChangeMediaServer: TButton
      Left = 257
      Top = 48
      Width = 126
      Height = 23
      Hint = 'Change video files folder'
      Action = ChangeMediaServRoot
      Anchors = [akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object LEdServMediaEFPath: TLabeledEdit
      Left = 88
      Top = 80
      Width = 296
      Height = 21
      Hint = 'Video files folder External Path'
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 72
      EditLabel.Height = 13
      EditLabel.Caption = 'External Path:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
  end
  object GBScanLocation: TGroupBox
    Left = 8
    Top = 360
    Width = 400
    Height = 177
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Client Capture Files  '
    TabOrder = 6
    DesignSize = (
      400
      177)
    object LEdScanDataPath: TLabeledEdit
      Left = 48
      Top = 16
      Width = 336
      Height = 21
      Hint = 'Current path to exchange folder'
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 34
      EditLabel.Height = 13
      EditLabel.Caption = 'Path:   '
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = LEdScanDataPathChange
    end
    object BtChangeScanDataPath: TButton
      Left = 257
      Top = 46
      Width = 126
      Height = 23
      Hint = 'Change current path to exchange folder'
      Action = ChangeMediaServRoot
      Anchors = [akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object LEdScanDataPathOld: TLabeledEdit
      Left = 63
      Top = 144
      Width = 320
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
    Top = 272
    Width = 400
    Height = 80
    Anchors = [akLeft, akTop, akRight]
    Caption = '  3D Image Files  '
    TabOrder = 7
    DesignSize = (
      400
      80)
    object LEdImg3DFPath: TLabeledEdit
      Left = 48
      Top = 16
      Width = 336
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
      Left = 257
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
    Left = 16
    Top = 548
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
    object ChangeMediaClientRoot: TAction
      Caption = 'Change Folder'
      OnExecute = ChangeMediaClientRootExecute
    end
    object ChangeImg3DRoot: TAction
      Caption = 'Change Folder'
      Hint = 'Change 3D image files folder on server computer'
      OnExecute = ChangeImg3DRootExecute
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 56
    Top = 548
  end
end
