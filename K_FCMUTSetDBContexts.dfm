inherited K_FormCMUTSetDBContexts: TK_FormCMUTSetDBContexts
  Left = 431
  Top = 289
  BorderStyle = bsDialog
  Caption = 'Toolbar settings'
  ClientHeight = 278
  ClientWidth = 346
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 336
    Top = 268
    TabOrder = 2
  end
  object BtRun: TButton
    Left = 184
    Top = 245
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = BtRunClick
  end
  object BtExit: TButton
    Left = 264
    Top = 245
    Width = 75
    Height = 23
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object GBToolbar: TGroupBox
    Left = 8
    Top = 8
    Width = 329
    Height = 225
    Anchors = [akLeft, akTop, akRight]
    Caption = '  Toolbar  '
    TabOrder = 3
    DesignSize = (
      329
      225)
    object GBToolBarSettings: TGroupBox
      Left = 8
      Top = 16
      Width = 313
      Height = 97
      Anchors = [akLeft, akTop, akRight]
      Caption = '  Settings value  '
      TabOrder = 0
      DesignSize = (
        313
        97)
      object LbLocations: TLabel
        Left = 8
        Top = 28
        Width = 81
        Height = 13
        Caption = 'Source Location:'
      end
      object CmBLocations: TComboBox
        Left = 96
        Top = 25
        Width = 209
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        Color = 10682367
        ItemHeight = 13
        TabOrder = 0
      end
      object ChBToAllLocations: TCheckBox
        Left = 8
        Top = 61
        Width = 297
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Apply to other Locations'
        TabOrder = 1
        OnClick = ChBToAllLocationsClick
      end
    end
    object GBToolbarUse: TGroupBox
      Left = 8
      Top = 120
      Width = 313
      Height = 97
      Anchors = [akLeft, akTop, akRight]
      Caption = '  Settings Use  '
      TabOrder = 1
      object LbUseType: TLabel
        Left = 8
        Top = 28
        Width = 46
        Height = 13
        Caption = 'UseType:'
      end
      object CmBUseType: TComboBox
        Left = 96
        Top = 25
        Width = 209
        Height = 21
        ItemHeight = 13
        TabOrder = 0
        Text = 'Use Toolbar Location Settings'
        Items.Strings = (
          'Use Toolbar Provider Settings'
          'Use Toolbar Location Settings'
          'Use Toolbar Global Settings')
      end
      object ChBToAllProviders: TCheckBox
        Left = 8
        Top = 61
        Width = 209
        Height = 17
        Caption = 'Apply to all Providers'
        TabOrder = 1
        OnClick = ChBToAllLocationsClick
      end
    end
  end
end
