object N_StrEditForm: TN_StrEditForm
  Left = 339
  Top = 298
  Width = 329
  Height = 130
  Caption = 'N_StrEditForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    321
    92)
  PixelsPerInch = 96
  TextHeight = 13
  object label1: TLabel
    Left = 9
    Top = 5
    Width = 34
    Height = 13
    Caption = 'label1 :'
  end
  object mb1: TComboBox
    Left = 8
    Top = 23
    Width = 297
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 4
    Text = 'mb1'
    Visible = False
    OnCloseUp = mb1CloseUp
  end
  object bnOk: TButton
    Left = 192
    Top = 64
    Width = 56
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object bnCancel: TButton
    Left = 256
    Top = 64
    Width = 56
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object edStr1: TLabeledEdit
    Left = 76
    Top = 23
    Width = 232
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 40
    EditLabel.Height = 13
    EditLabel.Caption = 'edStr1 : '
    LabelPosition = lpLeft
    TabOrder = 0
    Visible = False
    OnKeyDown = edkeyDown
  end
  object edStr2: TLabeledEdit
    Left = 76
    Top = 56
    Width = 81
    Height = 21
    EditLabel.Width = 40
    EditLabel.Height = 13
    EditLabel.Caption = 'edStr2 : '
    LabelPosition = lpLeft
    TabOrder = 1
    Visible = False
    OnKeyDown = edkeyDown
  end
end
