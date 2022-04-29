inherited K_FormCMSUDefFilter2: TK_FormCMSUDefFilter2
  Left = 78
  Top = 154
  Width = 316
  Height = 329
  Caption = 'Filter'
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 288
    Top = 278
  end
  inline K_FrameCMTeethChart11: TK_FrameCMTeethChart1
    Left = 0
    Top = 102
    Width = 300
    Height = 150
    TabOrder = 1
    inherited Image1: TImage
      Width = 300
      Height = 150
    end
  end
  object Button2: TButton
    Left = 227
    Top = 265
    Width = 66
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object Button1: TButton
    Left = 155
    Top = 265
    Width = 66
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 3
  end
  object Button3: TButton
    Left = 2
    Top = 265
    Width = 66
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Reset'
    TabOrder = 4
  end
  object GbMediaTypes: TGroupBox
    Left = 0
    Top = 50
    Width = 300
    Height = 46
    Anchors = [akTop, akRight]
    Caption = '  Media Category  '
    TabOrder = 5
    DesignSize = (
      300
      46)
    object CmBMediaTypes: TComboBox
      Left = 9
      Top = 15
      Width = 282
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      ItemHeight = 13
      TabOrder = 0
    end
  end
end
