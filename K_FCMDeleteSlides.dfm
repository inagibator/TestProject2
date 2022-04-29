inherited K_FormCMDeleteSlides: TK_FormCMDeleteSlides
  Left = 213
  Top = 312
  Width = 440
  Height = 242
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Delete media objects'
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 422
    Top = 198
  end
  object LbEDBMediaCount: TLabeledEdit
    Left = 140
    Top = 48
    Width = 279
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 131
    EditLabel.Height = 13
    EditLabel.Caption = 'Total number:                      '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object LbEDProcCount: TLabeledEdit
    Left = 140
    Top = 80
    Width = 279
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 130
    EditLabel.Height = 13
    EditLabel.Caption = 'Processed number:             '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object BtClose: TButton
    Left = 342
    Top = 169
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 2
    TabOrder = 3
  end
  object PBProgress: TProgressBar
    Left = 7
    Top = 145
    Width = 411
    Height = 16
    Anchors = [akLeft, akRight, akBottom]
    Smooth = True
    TabOrder = 4
  end
  object BtStart: TButton
    Left = 254
    Top = 169
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Resume'
    TabOrder = 5
    OnClick = BtStartClick
  end
  inline FileNameFrame: TN_FileNameFrame
    Tag = 161
    Left = -1
    Top = 8
    Width = 419
    Height = 27
    Anchors = [akLeft, akTop, akRight]
    PopupMenu = FileNameFrame.FilePopupMenu
    TabOrder = 6
    inherited mbFileName: TComboBox
      Width = 329
    end
    inherited bnBrowse_1: TButton
      Left = 395
    end
  end
  object LbEDDelCount: TLabeledEdit
    Left = 140
    Top = 112
    Width = 280
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 129
    EditLabel.Height = 13
    EditLabel.Caption = 'Deleted number:                 '
    EditLabel.Layout = tlCenter
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 7
  end
end
