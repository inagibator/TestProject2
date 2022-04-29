inherited K_FormAnalisesStrings: TK_FormAnalisesStrings
  Left = 420
  Top = 350
  Width = 1008
  Height = 449
  Caption = 'Strings Analises'
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 979
    Top = 397
  end
  object PnText: TPanel
    Left = 0
    Top = 0
    Width = 992
    Height = 361
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 473
      Top = 0
      Height = 361
    end
    object Memo1: TMemo
      Left = 0
      Top = 0
      Width = 473
      Height = 361
      Align = alLeft
      TabOrder = 0
    end
    object Memo2: TMemo
      Left = 476
      Top = 0
      Width = 516
      Height = 361
      Align = alClient
      Lines.Strings = (
        'Memo2')
      TabOrder = 1
    end
  end
  object Close: TButton
    Left = 909
    Top = 376
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 2
  end
  object LESearchPat: TLabeledEdit
    Left = 104
    Top = 376
    Width = 121
    Height = 21
    EditLabel.Width = 92
    EditLabel.Height = 13
    EditLabel.Caption = 'Search Expresion:  '
    LabelPosition = lpLeft
    TabOrder = 3
  end
  object LEOrderPat: TLabeledEdit
    Left = 328
    Top = 376
    Width = 121
    Height = 21
    EditLabel.Width = 84
    EditLabel.Height = 13
    EditLabel.Caption = 'Order Expresion:  '
    LabelPosition = lpLeft
    TabOrder = 4
  end
  object BtApply: TButton
    Left = 813
    Top = 376
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Apply'
    TabOrder = 5
    OnClick = BtApplyClick
  end
end
