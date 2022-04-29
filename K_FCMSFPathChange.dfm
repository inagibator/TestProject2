inherited K_FormCMSFPathChange: TK_FormCMSFPathChange
  Left = 588
  Top = 309
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Change Root Folder'
  ClientHeight = 276
  ClientWidth = 387
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object BtPause: TButton [0]
    Left = 8
    Top = 248
    Width = 375
    Height = 23
    Hint = 'Pause files moving operation'
    Action = CancelMoving
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Pause'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    Visible = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 377
    Top = 266
    TabOrder = 5
  end
  object BtCancel: TButton
    Left = 7
    Top = 248
    Width = 375
    Height = 23
    Action = CancelMoving
    Anchors = [akLeft, akRight, akBottom]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 7
    Top = 216
    Width = 375
    Height = 23
    Action = MoveFiles
    Anchors = [akLeft, akRight, akBottom]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
  end
  object GBCurLocation: TGroupBox
    Left = 8
    Top = 8
    Width = 372
    Height = 80
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Current folder  '
    TabOrder = 2
    DesignSize = (
      372
      80)
    object LbCurFilesAttrs: TLabel
      Left = 15
      Top = 50
      Width = 341
      Height = 13
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = '_Total number of files:         0,   Whole size:             0'
    end
    object LEdCurFPath: TLabeledEdit
      Left = 48
      Top = 16
      Width = 312
      Height = 21
      Hint = 'Files folder current path'
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
  end
  object GBNewLocation: TGroupBox
    Left = 8
    Top = 96
    Width = 372
    Height = 80
    Anchors = [akLeft, akTop, akRight]
    Caption = '  New folder  '
    TabOrder = 3
    DesignSize = (
      372
      80)
    object LbNewFilesAttrs: TLabel
      Left = 7
      Top = 50
      Width = 357
      Height = 13
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 
        '_Deleting files in previouse root folder. Remaining number of fi' +
        'les         0'
    end
    object LEdNewPath: TLabeledEdit
      Left = 48
      Top = 16
      Width = 281
      Height = 21
      Hint = 'Files folder new path'
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = 'Path:  '
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object BtPathSelect_1: TButton
      Left = 341
      Top = 16
      Width = 20
      Height = 23
      Hint = 'Select new Root Folder'
      Anchors = [akTop, akRight]
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = BtPathSelect_1Click
    end
  end
  object BtApply: TButton
    Left = 7
    Top = 184
    Width = 375
    Height = 23
    Action = ApplyPath
    Anchors = [akLeft, akRight, akBottom]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  object ActionList1: TActionList
    Left = 192
    Top = 80
    object MoveFiles: TAction
      Caption = '&Move files and set new folder'
      Hint = 'Move files and set new folder'
      OnExecute = MoveFilesExecute
    end
    object CancelMoving: TAction
      Caption = 'C&ancel operation'
      Hint = 'Cancel  files moving to new folder'
      OnExecute = CancelMovingExecute
    end
    object ApplyPath: TAction
      Caption = '&Check files and set new folder'
      Hint = 'Check files existance and set new folder'
      OnExecute = ApplyPathExecute
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 232
    Top = 80
  end
end
