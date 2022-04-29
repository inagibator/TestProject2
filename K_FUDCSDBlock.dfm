inherited K_FormUDCSDBlock: TK_FormUDCSDBlock
  Left = 326
  Top = 282
  Width = 561
  Height = 239
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1073#1083#1086#1082#1072' '#1076#1072#1085#1085#1099#1093
  Menu = MainMenu1
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LbID: TLabel [0]
    Left = 4
    Top = 165
    Width = 17
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'ID :'
  end
  object Label1: TLabel [1]
    Left = 223
    Top = 10
    Width = 71
    Height = 13
    Caption = #1041#1083#1086#1082' '#1076#1072#1085#1085#1099#1093' :'
  end
  inherited BFMinBRPanel: TPanel
    Left = 541
    Top = 173
    TabOrder = 7
  end
  object BtCancel: TButton
    Left = 425
    Top = 161
    Width = 57
    Height = 21
    Action = Cancel
    Anchors = [akRight, akBottom]
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 492
    Top = 161
    Width = 57
    Height = 21
    Action = OK
    Anchors = [akRight, akBottom]
    ModalResult = 1
    TabOrder = 1
  end
  object Button1: TButton
    Left = 330
    Top = 161
    Width = 71
    Height = 21
    Action = ApplyBlockData
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object EdID: TEdit
    Left = 24
    Top = 161
    Width = 288
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 3
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 209
    Height = 29
    Align = alNone
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Action = CreateUDCSDBlock
    end
    object ToolButton6: TToolButton
      Left = 25
      Top = 2
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 80
      Style = tbsSeparator
    end
    object ToolButton11: TToolButton
      Left = 33
      Top = 2
      Action = FrameCSDBlockEdit.TranspCurFrame
    end
    object ToolButton12: TToolButton
      Left = 58
      Top = 2
      Action = FrameCSDBlockEdit.RebuildCurFrame
    end
    object ToolButton3: TToolButton
      Left = 83
      Top = 2
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 0
      Style = tbsSeparator
    end
    object ToolButton2: TToolButton
      Left = 91
      Top = 2
      Action = FrameCSDBlockEdit.SetColCDRel
    end
    object ToolButton7: TToolButton
      Left = 116
      Top = 2
      Action = FrameCSDBlockEdit.ClearColCDRel
    end
    object ToolButton5: TToolButton
      Left = 141
      Top = 2
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 189
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 149
      Top = 2
      Action = FrameCSDBlockEdit.SetRowCDRel
    end
    object ToolButton8: TToolButton
      Left = 174
      Top = 2
      Action = FrameCSDBlockEdit.ClearRowCDRel
    end
  end
  inline FrUDList: TK_FrameUDList
    Left = 296
    Top = 4
    Width = 249
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    inherited UDIcon: TImage
      Visible = True
    end
    inherited CmB: TComboBox
      Width = 203
    end
    inherited BtTreeSelect: TButton
      Left = 226
    end
  end
  inline FrameCSDBlockEdit: TK_FrameCSDBlockEdit
    Left = 0
    Top = 31
    Width = 553
    Height = 126
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 6
    inherited PageControl: TPageControl
      Width = 553
      inherited DataTSheet: TTabSheet
        inherited Panel1: TPanel
          inherited ToolBar2: TToolBar
            inherited ToolButton13: TToolButton
              Action = FrameCSDBlockEdit.FrameCSDBDataEdit.AddCol
            end
            inherited ToolButton14: TToolButton
              Action = FrameCSDBlockEdit.FrameCSDBDataEdit.InsCol
            end
            inherited ToolButton15: TToolButton
              Action = FrameCSDBlockEdit.FrameCSDBDataEdit.DelCol
            end
            inherited ToolButton17: TToolButton
              Action = FrameCSDBlockEdit.FrameCSDBDataEdit.AddRow
            end
            inherited ToolButton18: TToolButton
              Action = FrameCSDBlockEdit.FrameCSDBDataEdit.InsRow
            end
            inherited ToolButton19: TToolButton
              Action = FrameCSDBlockEdit.FrameCSDBDataEdit.DelRow
            end
            inherited ToolButton2: TToolButton
              Action = FrameCSDBlockEdit.FrameCSDBDataEdit.ClearSelected
            end
          end
        end
      end
      inherited RowsTSheet: TTabSheet
        inherited FrameRowECDRel: TK_FrameECDRel
          inherited ToolBar1: TToolBar
            inherited TBTranspGrid: TToolButton
              Action = FrameCSDBlockEdit.FrameRowECDRel.FrRACDRel.TranspGrid
            end
            inherited TBRebuildGrid: TToolButton
              Action = FrameCSDBlockEdit.FrameRowECDRel.FrRACDRel.RebuildGrid
            end
            inherited ToolButton2: TToolButton
              Action = FrameCSDBlockEdit.FrameRowECDRel.FrRACDRel.DelCDim
            end
            inherited ToolButton4: TToolButton
              Action = FrameCSDBlockEdit.FrameRowECDRel.FrRACDRel.AddRow
            end
            inherited ToolButton5: TToolButton
              Action = FrameCSDBlockEdit.FrameRowECDRel.FrRACDRel.InsRow
            end
            inherited ToolButton6: TToolButton
              Action = FrameCSDBlockEdit.FrameRowECDRel.FrRACDRel.DelRow
            end
          end
        end
      end
      inherited ColsTSheet: TTabSheet
        inherited FrameColECDRel: TK_FrameECDRel
          Width = 545
          inherited ToolBar1: TToolBar
            inherited TBTranspGrid: TToolButton
              Action = FrameCSDBlockEdit.FrameColECDRel.FrRACDRel.TranspGrid
            end
            inherited TBRebuildGrid: TToolButton
              Action = FrameCSDBlockEdit.FrameColECDRel.FrRACDRel.RebuildGrid
            end
            inherited ToolButton2: TToolButton
              Action = FrameCSDBlockEdit.FrameColECDRel.FrRACDRel.DelCDim
            end
            inherited ToolButton4: TToolButton
              Action = FrameCSDBlockEdit.FrameColECDRel.FrRACDRel.AddRow
            end
            inherited ToolButton5: TToolButton
              Action = FrameCSDBlockEdit.FrameColECDRel.FrRACDRel.InsRow
            end
            inherited ToolButton6: TToolButton
              Action = FrameCSDBlockEdit.FrameColECDRel.FrRACDRel.DelRow
            end
          end
          inherited FrRACDRel: TK_FrameCDRel
            Width = 545
            inherited SGrid: TStringGrid
              Width = 545
            end
          end
          inherited CmBIndsType: TComboBox
            Width = 135
          end
        end
      end
      inherited CSItemsTSheet: TTabSheet
        inherited Panel2: TPanel
          inherited Button3: TButton
            Action = FrameCSDBlockEdit.FrameCDIRefs.DelRow
          end
        end
      end
    end
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 110
    Top = 158
    object ApplyBlockData: TAction
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      Hint = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      OnExecute = ApplyBlockDataExecute
    end
    object CreateUDCSDBlock: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1086#1073#1098#1077#1082#1090' ...'
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1086#1073#1098#1077#1082#1090' ...'
      ImageIndex = 0
      OnExecute = CreateUDCSDBlockExecute
    end
    object RenameUDCSDBlock: TAction
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1086#1073#1098#1077#1082#1090' ...'
      Hint = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1086#1073#1098#1077#1082#1090' ...'
    end
    object CloseAction: TAction
      Caption = #1042#1099#1093#1086#1076
      Hint = #1042#1099#1093#1086#1076
    end
    object OK: TAction
      Caption = 'OK'
      OnExecute = OKExecute
    end
    object Cancel: TAction
      Caption = #1054#1090#1082#1072#1079
      OnExecute = CancelExecute
    end
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 86
    Top = 158
    object N1: TMenuItem
      Caption = #1054#1073#1098#1077#1082#1090
      object N2: TMenuItem
        Action = CreateUDCSDBlock
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1073#1083#1086#1082' '#1076#1072#1085#1085#1099#1093' ...'
      end
      object N5: TMenuItem
        Action = FrUDList.SelectUDObj
        Caption = #1042#1099#1073#1088#1072#1090#1100' '#1073#1083#1086#1082' '#1076#1072#1085#1085#1099#1093' ...'
        Hint = #1042#1099#1073#1088#1072#1090#1100' '#1073#1083#1086#1082' '#1076#1072#1085#1085#1099#1093' ...'
      end
      object N3: TMenuItem
        Action = RenameUDCSDBlock
        Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1073#1083#1086#1082' '#1076#1072#1085#1085#1099#1093' ...'
        Hint = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1073#1083#1086#1082' '#1076#1072#1085#1085#1099#1093' ...'
      end
      object N4: TMenuItem
        Action = CloseAction
      end
    end
  end
end
