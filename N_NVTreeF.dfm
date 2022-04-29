inherited N_NVTreeForm: TN_NVTreeForm
  Left = 218
  Top = 169
  Width = 392
  Height = 372
  Caption = ' Archive Objects'
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = True
  ShowHint = True
  OnActivate = FormActivate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 374
    Top = 304
    TabOrder = 1
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 384
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar1'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 0
    object tbSetOnDoubleClickAction: TToolButton
      Left = 0
      Top = 2
      Hint = 'Choose one of Actions for  "DoubleClick" '
      Caption = 'Choose one of  "DoubleClick"  Actions'
      OnClick = tbnSetOnClickActionClick
    end
    object tbSetOnRClickShiftAction: TToolButton
      Tag = 1
      Left = 25
      Top = 2
      Hint = 'Choose one of Actions for  "RightClick+Shift" '
      Caption = 'Choose one of  "RightClick+Shift" Actions'
      OnClick = tbnSetOnClickActionClick
    end
    object tbSetOnRClickCtrlAction: TToolButton
      Tag = 2
      Left = 50
      Top = 2
      Hint = 'Choose one of Actions for "RightClick+Control"'
      Caption = 'Choose one of  "RightClick+Control" Actions'
      OnClick = tbnSetOnClickActionClick
    end
    object ToolButton5: TToolButton
      Left = 75
      Top = 2
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object ToolButton6: TToolButton
      Left = 83
      Top = 2
      Action = NVTreeFrame.aEdCutMarked
    end
    object ToolButton7: TToolButton
      Left = 108
      Top = 2
      Action = NVTreeFrame.aEdCopyMarked
    end
    object ToolButton15: TToolButton
      Left = 133
      Top = 2
      Action = NVTreeFrame.aEdPasteSubTreesAny
    end
    object ToolButton9: TToolButton
      Left = 158
      Top = 2
      Action = NVTreeFrame.aEdDeleteMarked
    end
    object ToolButton10: TToolButton
      Left = 183
      Top = 2
      Width = 8
      Caption = 'ToolButton10'
      ImageIndex = 77
      Style = tbsSeparator
    end
    object ToolButton11: TToolButton
      Left = 191
      Top = 2
      Action = NVTreeFrame.MoveNodeUP
    end
    object ToolButton12: TToolButton
      Left = 216
      Top = 2
      Action = NVTreeFrame.MoveNodeDown
    end
    object ToolButton1: TToolButton
      Left = 241
      Top = 2
      Action = NVTreeFrame.aViewRefreshFrame
    end
    object ToolButton2: TToolButton
      Left = 266
      Top = 2
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 77
      Style = tbsSeparator
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 295
    Width = 384
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  inline NVTreeFrame: TN_NVTreeFrame
    Left = 0
    Top = 58
    Width = 384
    Height = 212
    Align = alClient
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 2
    TabStop = True
    inherited TreeView: TTreeView
      Width = 384
      Height = 212
    end
    inherited NVTreeActionList: TActionList
      Left = 350
      Top = 23
      inherited aEdCreateNewUObj: TAction
        Hint = 'Create New UObj ...'
      end
      inherited aDebCheckArchConsistency: TAction
        ImageIndex = 123
      end
      inherited aOtherShowOptionsForm: TAction
        ImageIndex = 139
      end
    end
  end
  inline FrFormFName: TN_FileNameFrame
    Tag = 161
    Left = 0
    Top = 270
    Width = 384
    Height = 25
    Align = alBottom
    PopupMenu = FrFormFName.FilePopupMenu
    TabOrder = 3
    TabStop = True
    Visible = False
    inherited mbFileName: TComboBox
      Left = 1
      Width = 358
    end
    inherited bnBrowse_1: TButton
      Left = 361
      Width = 21
    end
  end
  object ToolBar2: TToolBar
    Left = 0
    Top = 29
    Width = 384
    Height = 29
    ButtonHeight = 24
    ButtonWidth = 25
    Caption = 'ToolBar2'
    Images = N_ButtonsForm.ButtonsList
    TabOrder = 4
    object tbToggleEditMark: TToolButton
      Left = 0
      Top = 2
      Caption = 'tbToggleEditMark'
      ImageIndex = 86
      Visible = False
      OnClick = tbToggleEditMarkClick
    end
    object ToolButton3: TToolButton
      Left = 25
      Top = 2
      Action = NVTreeFrame.aOtherShowOptionsForm
    end
    object ToolButton4: TToolButton
      Left = 50
      Top = 2
      Action = NVTreeFrame.aOtherExportComp
    end
    object ToolButton14: TToolButton
      Left = 75
      Top = 2
      Action = NVTreeFrame.aOtherAlign
    end
    object ToolButton16: TToolButton
      Left = 100
      Top = 2
      Action = NVTreeFrame.aEdCreateNewUObj
    end
    object ToolButton17: TToolButton
      Left = 125
      Top = 2
      Width = 8
      Caption = 'ToolButton17'
      ImageIndex = 61
      Style = tbsSeparator
    end
    object ToolButton8: TToolButton
      Left = 133
      Top = 2
      Action = NVTreeFrame.aEdEditUObjInfo
    end
    object ToolButton13: TToolButton
      Left = 158
      Top = 2
      Action = NVTreeFrame.aDebTmpAction1
    end
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 274
    Top = 80
    object File1: TMenuItem
      Caption = 'File'
      object LoadBellow1: TMenuItem
        Action = NVTreeFrame.aFileLoadBefore
      end
      object aFileLoadInside1: TMenuItem
        Action = NVTreeFrame.aFileLoadInside
      end
      object LoadInsteadofMarked1: TMenuItem
        Action = NVTreeFrame.aFileLoadInstead
      end
      object LoadAndReplace1: TMenuItem
        Action = NVTreeFrame.aFileLoadFields
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object SaveSelected1: TMenuItem
        Action = NVTreeFrame.aFileSaveUObjects
      end
      object SaveFields1: TMenuItem
        Action = NVTreeFrame.aFileSaveFields
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object EditSeparateArchiveFlags1: TMenuItem
        Action = NVTreeFrame.aFileEditArchSectionParams
      end
      object LoadMarkedArchiveSections1: TMenuItem
        Action = NVTreeFrame.aFileLoadArchSections
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object CreateNewUObj1: TMenuItem
        Action = NVTreeFrame.aEdCreateNewUObj
      end
      object CutCopyPaste1: TMenuItem
        Caption = 'Cut/Copy/Paste'
        object CutMarked1: TMenuItem
          Action = NVTreeFrame.aEdCutMarked
        end
        object CopyMarked1: TMenuItem
          Action = NVTreeFrame.aEdCopyMarked
        end
        object N9: TMenuItem
          Caption = '-'
        end
        object PasteRefsBefore1: TMenuItem
          Action = NVTreeFrame.aEdPasteRefsBefore
        end
        object PasteRefsAfterAllMarked1: TMenuItem
          Action = NVTreeFrame.aEdPasteRefsAfter
        end
        object PasteRefsInside1: TMenuItem
          Action = NVTreeFrame.aEdPasteRefsInside
        end
        object PasteRefsInstead1: TMenuItem
          Action = NVTreeFrame.aEdPasteRefsInstead
        end
        object N10: TMenuItem
          Caption = '-'
        end
        object PasteOneLevelClonesBefore1: TMenuItem
          Action = NVTreeFrame.aEdPasteOLCBefore
        end
        object PasteOneLevelClonesAfterAllMarked1: TMenuItem
          Action = NVTreeFrame.aEdPasteOLCAfter
        end
        object PasteOneLevelClonesInside1: TMenuItem
          Action = NVTreeFrame.aEdPasteOLCInside
        end
        object PasteOneLevelClonesInstead1: TMenuItem
          Action = NVTreeFrame.aEdPasteOLCInstead
        end
        object N11: TMenuItem
          Caption = '-'
        end
        object PasteSubTreesClonesBefore1: TMenuItem
          Action = NVTreeFrame.aEdPasteSubTreesBefore
        end
        object PasteSubTreeClonesAfterAllMarekd1: TMenuItem
          Action = NVTreeFrame.aEdPasteSubTreesAfter
        end
        object PasteSubTreesClonesInside1: TMenuItem
          Action = NVTreeFrame.aEdPasteSubTreesInside
        end
        object PasteSubTreesClonesInstead1: TMenuItem
          Action = NVTreeFrame.aEdPasteSubTreesInstead
        end
      end
      object DeleteMarked1: TMenuItem
        Action = NVTreeFrame.aEdDeleteMarked
      end
      object EditUObjInfo1: TMenuItem
        Action = NVTreeFrame.aEdEditUObjInfo
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object ForceSingleOneLevelInstance1: TMenuItem
        Action = NVTreeFrame.aEdForceSingleOneLevelInstance
      end
      object ForceSingleSubTreeInstance1: TMenuItem
        Action = NVTreeFrame.aEdForceSingleSubTreeInstance
      end
      object SetNewOwnerstoMarked1: TMenuItem
        Action = NVTreeFrame.aEdSetVisualOwnersToMarked
      end
      object aEdClearUObjWasChangedBit1: TMenuItem
        Action = NVTreeFrame.aEdClearUObjWasChangedBit
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object UnresolveRefsInSelectedSubTree1: TMenuItem
        Action = NVTreeFrame.aEdUnresolveRefsInSelected
      end
      object ResolveRefsInSelectedSubTree1: TMenuItem
        Action = NVTreeFrame.aEdResolveRefsInSelected
      end
      object ClearUnresolvedRefsinSelectedSubTree1: TMenuItem
        Action = NVTreeFrame.aEdClearUnresolvedRefs
      end
      object RedirectRefsinSubTree1: TMenuItem
        Action = NVTreeFrame.aEdRedirectRefs
      end
      object ReplaceMarkedUObjects1: TMenuItem
        Action = NVTreeFrame.aEdReplaceUObjects
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object ViewRefsToSelectedSubTree1: TMenuItem
        Action = NVTreeFrame.aViewEntriesInSubTree
      end
      object ViewPathsToUObj1: TMenuItem
        Action = NVTreeFrame.aViewRefsToMarked
      end
      object ViewRefsFromSelectedSubTree1: TMenuItem
        Action = NVTreeFrame.aViewRefsFromSubTree
      end
      object ViewRefsBetweenSubtrees1: TMenuItem
        Action = NVTreeFrame.aViewRefsBetween
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object RefreshFrame1: TMenuItem
        Action = NVTreeFrame.aViewRefreshFrame
      end
      object CloseChildForms1: TMenuItem
        Action = NVTreeFrame.aViewCloseOwnedForms
      end
    end
    object Other1: TMenuItem
      Caption = 'Other'
      object AlignComponents1: TMenuItem
        Action = NVTreeFrame.aOtherAlign
      end
      object ExportComponent1: TMenuItem
        Action = NVTreeFrame.aOtherExportComp
      end
      object ShowVideoDevices1: TMenuItem
        Action = NVTreeFrame.aOtherShowVideoDevs
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object SetNewNamesofMarked1: TMenuItem
        Action = NVTreeFrame.aOtherSetMarkedObjNames
      end
      object SetCSCodesinMarkedSubTrees1: TMenuItem
        Action = NVTreeFrame.aOtherSetMarkedCSCodes
      end
      object MarkMarkedChildren1: TMenuItem
        Action = NVTreeFrame.aOtherMarkChildren
      end
      object ShowStatisticsaboutMarked1: TMenuItem
        Action = NVTreeFrame.aOtherShowStatistics
      end
      object Options1: TMenuItem
        Action = NVTreeFrame.aOtherShowOptionsForm
      end
      object N12: TMenuItem
        Action = NVTreeFrame.StepUp
      end
      object N13: TMenuItem
        Action = NVTreeFrame.StepDown
      end
    end
    object Spec11: TMenuItem
      Caption = 'Spec1'
      object CoordsObjects1: TMenuItem
        Caption = 'Coords Objects'
        object oggleCObjRunTimeFlag2: TMenuItem
          Action = NVTreeFrame.aSp1ChangeCObjRT
        end
      end
      object Components1: TMenuItem
        Caption = 'Components'
        object oggleCompSkipExecFlag1: TMenuItem
          Action = NVTreeFrame.aSp1ChangeCompSkip
        end
        object ViewCleaRAFields: TMenuItem
          Action = NVTreeFrame.aSp1ViewClearRAFields
        end
      end
    end
    object Debug1: TMenuItem
      Caption = 'Deb1'
      object ViewUObjectsinClipboard1: TMenuItem
        Action = NVTreeFrame.aDebViewClipboard
      end
      object ViewMarkedUObjects1: TMenuItem
        Action = NVTreeFrame.aDebViewMarked
      end
      object ViewCompCoords1: TMenuItem
        Action = NVTreeFrame.aDebViewCompCoords
      end
      object CheckArchiveConsistency1: TMenuItem
        Action = NVTreeFrame.aDebCheckArchConsistency
      end
      object CheckProjectConsistency1: TMenuItem
        Action = NVTreeFrame.aDebCheckProject
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mpAction11: TMenuItem
        Action = NVTreeFrame.aDebTmpAction1
      end
      object mpAction21: TMenuItem
        Action = NVTreeFrame.aDebTmpAction2
      end
      object mpAction31: TMenuItem
        Action = NVTreeFrame.aDebTmpAction3
      end
    end
    object Debug2: TMenuItem
      Caption = 'Deb2'
      object RunWordMacro1: TMenuItem
        Action = NVTreeFrame.aDeb2RunWMacro
      end
    end
  end
  object ChooseActionPopupMenu: TPopupMenu
    AutoPopup = False
    Images = N_ButtonsForm.ButtonsList
    Left = 312
    Top = 80
    object miNoAction: TMenuItem
      AutoCheck = True
      Caption = 'No Action'
      ImageIndex = 16
      RadioItem = True
      OnClick = miSetOnClickAction
    end
    object miViewAsMap: TMenuItem
      Tag = 1
      AutoCheck = True
      Caption = 'View As Map'
      ImageIndex = 33
      RadioItem = True
      OnClick = miSetOnClickAction
    end
    object miViewInfo: TMenuItem
      Tag = 2
      AutoCheck = True
      Caption = 'View Info'
      ImageIndex = 31
      RadioItem = True
      OnClick = miSetOnClickAction
    end
    object miEditCompParams: TMenuItem
      Tag = 3
      AutoCheck = True
      Caption = 'Edit Component'
      ImageIndex = 65
      RadioItem = True
      OnClick = miSetOnClickAction
    end
  end
end
