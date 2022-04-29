object N_NVtreeOptionsForm: TN_NVtreeOptionsForm
  Left = 393
  Top = 332
  Width = 366
  Height = 314
  Caption = 'N_NVtreeOptionsForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    358
    280)
  PixelsPerInch = 96
  TextHeight = 13
  object bnOK: TButton
    Left = 310
    Top = 252
    Width = 42
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 0
    OnClick = bnOKClick
  end
  object bnCancel: TButton
    Left = 266
    Top = 252
    Width = 42
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = bnCancelClick
  end
  object bnApply: TButton
    Left = 222
    Top = 252
    Width = 42
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Apply'
    TabOrder = 2
    OnClick = bnApplyClick
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 358
    Height = 241
    ActivePage = tsFlags1
    Align = alTop
    TabOrder = 3
    object tsFlags1: TTabSheet
      Caption = 'Flags1'
      object cbAutoIncCSCodes: TCheckBox
        Left = 16
        Top = 16
        Width = 169
        Height = 17
        Caption = 'Auto Increment CS Codes'
        TabOrder = 0
      end
      object cbUncondDelete: TCheckBox
        Left = 16
        Top = 33
        Width = 176
        Height = 17
        Caption = 'Unconditional Delete UObjects'
        TabOrder = 1
      end
      object cbSkipAutoRefsToUDVect: TCheckBox
        Left = 16
        Top = 51
        Width = 176
        Height = 17
        Caption = 'Skip Auto Refs To UDVectors'
        TabOrder = 2
      end
      object cbNewEdWindow: TCheckBox
        Left = 16
        Top = 68
        Width = 185
        Height = 17
        Caption = 'New EdWindows if Shift Pressed'
        TabOrder = 3
      end
      object cbAddUObjSysInfo: TCheckBox
        Left = 16
        Top = 86
        Width = 176
        Height = 17
        Caption = 'Add UObj Sys Info'
        TabOrder = 4
      end
      object cbStayOnTop: TCheckBox
        Left = 16
        Top = 140
        Width = 176
        Height = 17
        Caption = 'Stay On Top'
        TabOrder = 5
      end
      object cbHideFileNameFrame: TCheckBox
        Left = 16
        Top = 104
        Width = 175
        Height = 17
        Caption = 'Hide FileName Frame'
        TabOrder = 6
      end
      object cbNotUseRefInds: TCheckBox
        Left = 16
        Top = 122
        Width = 176
        Height = 17
        Caption = 'Do not use RefInds while loading'
        TabOrder = 7
      end
      object cbAutoViewReport: TCheckBox
        Left = 16
        Top = 159
        Width = 129
        Height = 17
        Caption = 'Auto View Report'
        TabOrder = 8
      end
      object cbAliasesInPaths: TCheckBox
        Left = 17
        Top = 178
        Width = 135
        Height = 16
        Caption = 'Use Aliases In Paths'
        TabOrder = 9
      end
    end
    object tsFlags2: TTabSheet
      Caption = 'Flags2'
      ImageIndex = 2
      object cbVeiwFieldsAsTextAll: TCheckBox
        Left = 8
        Top = 16
        Width = 257
        Height = 17
        Caption = 'View/Edit Fields As Text - All Fields Mode'
        TabOrder = 0
      end
    end
    object tsGetUObjFrMenu: TTabSheet
      Caption = 'RC Menu'
      ImageIndex = 1
      object clbUObjFrMenu: TCheckListBox
        Left = 0
        Top = 0
        Width = 350
        Height = 213
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
      end
    end
    object tsView: TTabSheet
      Caption = 'View'
      ImageIndex = 3
      object rgViewMode: TRadioGroup
        Left = 24
        Top = 16
        Width = 185
        Height = 145
        Caption = 'View Mode'
        Items.Strings = (
          'Common Window'
          'Separate Window'
          'Default Brauser'
          'MS Word')
        TabOrder = 0
      end
    end
  end
end
