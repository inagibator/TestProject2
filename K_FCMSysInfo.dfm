inherited K_FormCMSysInfo: TK_FormCMSysInfo
  Left = 556
  Top = 379
  Width = 494
  Height = 363
  BorderIcons = [biSystemMenu]
  Caption = 'System Info'
  Constraints.MinHeight = 273
  Constraints.MinWidth = 492
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbCapt: TLabel [0]
    Left = 16
    Top = 9
    Width = 464
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'The following data should be included in your normal backup rout' +
      'ine:'
  end
  object LbProcessphase: TLabel [1]
    Left = 12
    Top = 297
    Width = 63
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Preparing DB'
    Visible = False
  end
  object LbLicenseInfo: TLabel [2]
    Left = 12
    Top = 232
    Width = 39
    Height = 13
    Caption = '?? of ??'
    Visible = False
  end
  object LbComment: TLabel [3]
    Left = 16
    Top = 264
    Width = 205
    Height = 13
    Caption = '* - paths are relative to the Server computer'
  end
  inherited BFMinBRPanel: TPanel
    Left = 465
    Top = 312
    Width = 11
  end
  object LbEDBFile: TLabeledEdit
    Left = 116
    Top = 40
    Width = 356
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 102
    EditLabel.Height = 13
    EditLabel.Caption = 'Database file  *          '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object LbEDBLogFile: TLabeledEdit
    Left = 116
    Top = 72
    Width = 356
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 102
    EditLabel.Height = 13
    EditLabel.Caption = 'Database Log file  *   '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object LbEImgFiles: TLabeledEdit
    Left = 116
    Top = 104
    Width = 356
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 101
    EditLabel.Height = 13
    EditLabel.Caption = 'Image files                 '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 3
  end
  object LbEVideoFiles: TLabeledEdit
    Left = 116
    Top = 136
    Width = 356
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 102
    EditLabel.Height = 13
    EditLabel.Caption = 'Video files                  '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 4
  end
  object LbETotal: TLabeledEdit
    Left = 116
    Top = 200
    Width = 356
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 102
    EditLabel.Height = 13
    EditLabel.Caption = 'Total                          '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 5
  end
  object BtClose: TButton
    Left = 395
    Top = 291
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 6
  end
  object PBProgress: TProgressBar
    Left = 117
    Top = 296
    Width = 240
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 7
    Visible = False
  end
  object LbEImg3DFiles: TLabeledEdit
    Left = 116
    Top = 168
    Width = 356
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 103
    EditLabel.Height = 13
    EditLabel.Caption = '3D Image files            '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 8
  end
  object BtCancel: TButton
    Left = 395
    Top = 251
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 9
    OnClick = BtCancelClick
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 16
    Top = 8
  end
end
