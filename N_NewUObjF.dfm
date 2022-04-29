object N_NewUObjForm: TN_NewUObjForm
  Left = 163
  Top = 340
  Width = 226
  Height = 224
  Caption = 'Create New Object'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    218
    186)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 34
    Width = 33
    Height = 13
    Caption = 'Type : '
  end
  object Label2: TLabel
    Left = 8
    Top = 10
    Width = 35
    Height = 13
    Caption = 'Group :'
  end
  object edName: TLabeledEdit
    Left = 47
    Top = 69
    Width = 163
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 37
    EditLabel.Height = 13
    EditLabel.Caption = 'Name : '
    LabelPosition = lpLeft
    TabOrder = 0
    OnKeyDown = edNameKeyDown
  end
  object edAliase: TLabeledEdit
    Left = 47
    Top = 96
    Width = 163
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 37
    EditLabel.Height = 13
    EditLabel.Caption = 'Aliase : '
    LabelPosition = lpLeft
    TabOrder = 1
  end
  object bnCancel: TButton
    Left = 145
    Top = 125
    Width = 56
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object bnOK: TButton
    Left = 145
    Top = 157
    Width = 57
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
  object mbUObjType: TComboBox
    Left = 47
    Top = 31
    Width = 164
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 20
    ItemHeight = 13
    TabOrder = 4
    OnCloseUp = mbUObjTypeCloseUp
  end
  object rgWhere: TRadioGroup
    Left = 12
    Top = 121
    Width = 67
    Height = 61
    Caption = 'Where'
    ItemIndex = 0
    Items.Strings = (
      'Before'
      'Inside'
      'After')
    TabOrder = 5
  end
  object mbTGroup: TComboBox
    Left = 47
    Top = 5
    Width = 164
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    DropDownCount = 20
    ItemHeight = 13
    TabOrder = 6
    OnCloseUp = mbTGroupCloseUp
    Items.Strings = (
      'Empty Dir'
      'Comp. Data Dir'
      'Panel'
      'Text Box'
      'Legend'
      'Picture'
      'Map'
      'Map Layer'
      'Font'
      'Text'
      '-------------'
      'UDRArray'
      'UDSetParams'
      'CTParams Var1'
      '-------------'
      'SignMapLayer'
      'Panel & SignMapLayer'
      'Panel & Header '
      'Panel & Header & Legend'
      '')
  end
end
