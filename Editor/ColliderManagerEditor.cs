/* 
 * Copyright (C) 2021 Victor Soupday
 * This file is part of CC_Unity_Tools <https://github.com/soupday/CC_Unity_Tools>
 * 
 * CC_Unity_Tools is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * CC_Unity_Tools is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with CC_Unity_Tools.  If not, see <https://www.gnu.org/licenses/>.
 */

using UnityEngine;
using UnityEditor;
using ColliderSettings = Reallusion.Import.ColliderManager.ColliderSettings;
using System.Linq;
using System.Collections.Generic;
using System;
using Object = UnityEngine.Object;
using System.Collections;

namespace Reallusion.Import
{
	[CustomEditor(typeof(ColliderManager))]
	public class ColliderManagerEditor : Editor
	{        
		private bool drawAllGizmos = true;
		private bool resetAfterGUI = false;
        private bool recallAfterGUI = false;
		private Styles colliderManagerStyles;

        private ColliderManager colliderManager;
		private ColliderSettings currentCollider;
		private bool symmetrical = true;
        private Texture2D editModeEnable, editModeDisable;
		private Color baseBackground;

        const float LABEL_WIDTH = 80f;
		const float GUTTER = 40f;
		const float BUTTON_WIDTH = 160f;

        [SerializeField] private GizmoState cachedGizmoState;
        [SerializeField] private bool editMode = false;
        [SerializeField] private bool activeEdit = false;

        public static string CURRENT_COLLIDER_NAME
		{
			get
			{
				if (EditorPrefs.HasKey("RL_Current_Collider_Name"))
					return EditorPrefs.GetString("RL_Current_Collider_Name");
				return "";
			}

			set
			{
				EditorPrefs.SetString("RL_Current_Collider_Name", value);
			}
		}

		private void OnEnable()
		{
            Debug.Log("OnEnable");
			colliderManager = (ColliderManager)target;
			//InitCurrentCollider(CURRENT_COLLIDER_NAME);
            CreateAbstractColliders();
            InitIcons();
        }

        private void OnDestroy()
        {
            Debug.Log("OnDestroy");            
        }

        private void OnDisable()
        {
            Debug.Log("OnDisable");
        }

        private void InitCurrentCollider(string name = null)
        {
            currentCollider = null;

			if (colliderManager.settings.Length > 0)
            {
                if (!string.IsNullOrEmpty(name))
				{
					foreach (ColliderSettings cs in colliderManager.settings)
					{
						if (cs.name == name)
						{
							currentCollider = cs;
							return;
						}
					}					
				}

				currentCollider = colliderManager.settings[0];				
			}
		}

        private void CreateAbstractColliders()
        {
            Physics.CreateAbstractColliders(colliderManager, out colliderManager.abstractedCapsuleColliders, out colliderManager.genericColliderList);
        }
        
		private void InitIcons()
		{
			editModeEnable = Util.FindTexture(new string[] { "Assets", "Packages" }, "RL_Edit_Enable");
			editModeDisable = Util.FindTexture(new string[] { "Assets", "Packages" }, "RL_Edit_Disable");
        }

        public class Styles
		{
            public GUIStyle sceneLabelText;
            public GUIStyle objectLabelText;
			public GUIStyle normalButton;
            public GUIStyle currentButton;

            public Styles()
            {
                sceneLabelText = new GUIStyle();
                sceneLabelText.normal.textColor = Color.cyan;
                sceneLabelText.fontSize = 18;

                objectLabelText = new GUIStyle();
                objectLabelText.normal.textColor = Color.red;
                objectLabelText.fontSize = 12;

                normalButton = new GUIStyle(GUI.skin.button);                
                currentButton = new GUIStyle(GUI.skin.button);
				currentButton.normal.background = TextureColor(new Color(0.3f, 0.3f, 0.63f, 0.5f));
            }
        }

        private void OnSceneGUI()
        {
			if (colliderManagerStyles == null) colliderManagerStyles = new Styles();

			string selectedName = "";

            if (colliderManager.abstractedCapsuleColliders != null)
            {
                foreach (ColliderManager.AbstractCapsuleCollider c in colliderManager.abstractedCapsuleColliders)
                {
                    Color drawCol = c == colliderManager.selectedAbstractCapsuleCollider ? Color.red : new Color(0.60f, 0.9f, 0.60f);
                    if (colliderManager.selectedAbstractCapsuleCollider == c)
                    {
                        selectedName = c.name;
						//small floating annotation near the collider                        
                        Handles.Label(c.transform.position + Vector3.up * 0.1f + Vector3.left * 0.1f, c.name, colliderManagerStyles.objectLabelText);
                        
                        DrawWireCapsule(c.transform.position, c.transform.rotation, c.radius, c.height, c.axis, drawCol);
                        switch (colliderManager.manipulator)
                        {
                            case ColliderManager.ManipulatorType.position:
                                {
                                    /*
                                    //if (!ColliderManager.AbstractCapsuleCollider .IsNullOrEmpty(colliderManager.mirrorImageAbstractCapsuleCollider))
                                    if (colliderManager.mirrorImageAbstractCapsuleCollider != null)
                                    {
                                        Debug.Log("OnSceneGUI: mirrorImageAbstractCapsuleCollider is NOT NULL - " + colliderManager.mirrorImageAbstractCapsuleCollider.name);
                                    }
                                    else
                                    {
                                        Debug.Log("OnSceneGUI: mirrorImageAbstractCapsuleCollider is NULL");
                                    }
                                    */

                                    Vector3 targetPosition = c.transform.position;									
                                    EditorGUI.BeginChangeCheck();
                                    targetPosition = Handles.PositionHandle(targetPosition, c.transform.rotation);
                                    if (EditorGUI.EndChangeCheck())
                                    {
                                        //if (colliderManager.mirrorImageAbstractCapsuleCollider != null)
                                        if (!ColliderManager.AbstractCapsuleCollider.IsNullOrEmpty(colliderManager.mirrorImageAbstractCapsuleCollider))
                                        {
											Vector3 delta = c.transform.parent.InverseTransformPoint(targetPosition) - c.transform.parent.InverseTransformPoint(c.transform.position);
											Quaternion inv = Quaternion.Inverse(c.transform.localRotation);
                                            Vector3 diff = inv * delta;
                                            colliderManager.UpdateColliderFromAbstract(c.transform.localPosition, c.transform.localRotation);
										}
                                        c.transform.position = targetPosition;
                                    }
                                    break;
                                }
                            case ColliderManager.ManipulatorType.rotation:
                                {
                                    Quaternion targetRotation = c.transform.rotation;
									Quaternion currentLocalRotation = c.transform.localRotation;
                                    EditorGUI.BeginChangeCheck();
                                    targetRotation = Handles.RotationHandle(targetRotation, c.transform.position);									
                                    if (EditorGUI.EndChangeCheck())
                                    {
										Quaternion targetLocalRotation = Quaternion.Inverse(c.transform.parent.rotation) * targetRotation;
                                        //if (colliderManager.mirrorImageAbstractCapsuleCollider != null)
                                        if (!ColliderManager.AbstractCapsuleCollider.IsNullOrEmpty(colliderManager.mirrorImageAbstractCapsuleCollider))
                                        {
                                            Vector3 rDiff = targetLocalRotation.eulerAngles - currentLocalRotation.eulerAngles;                                                                                        
                                            colliderManager.UpdateColliderFromAbstract(c.transform.localPosition, targetLocalRotation);
                                        }
										c.transform.rotation = targetRotation;
									}
									
									break;
                                }
                            case ColliderManager.ManipulatorType.scale:
                                {
                                    Handles.color = Color.green;
                                    EditorGUI.BeginChangeCheck();
									float h = c.height;
									float r = c.radius;
                                    h = Handles.ScaleValueHandle(h,
                                                                c.transform.position + c.transform.up * h * 0.5f,
                                                                c.transform.rotation * Quaternion.Euler(90, 0, 0),
                                                                0.075f, Handles.DotHandleCap, 1);

                                    Handles.DrawWireArc(c.transform.position,
                                                        c.transform.up,
                                                        -c.transform.right,
                                                        180,
                                                        r);

                                    r = Handles.ScaleValueHandle(r,
                                                                c.transform.position + c.transform.forward * r * 1f,
                                                                c.transform.rotation,
                                                                0.075f, Handles.DotHandleCap, 1);

                                    if (EditorGUI.EndChangeCheck())
                                    {
										c.radius = r;
										c.height = h;
										colliderManager.UpdateColliderFromAbstract(c.transform.localPosition, c.transform.localRotation);
                                    }
                                    break;
                                }
                        }
					}
					else
					{
						if (Selection.objects.Contains(colliderManager.gameObject))
						{
							drawAllGizmos = false;
                            if (colliderManager.mirrorImageAbstractCapsuleCollider == c)
								DrawWireCapsule(c.transform.position, c.transform.rotation, c.radius, c.height, c.axis, Color.magenta);
                        }
						else
							drawAllGizmos = true;

						if (drawAllGizmos)
						{
							if (colliderManager.mirrorImageAbstractCapsuleCollider == c) drawCol = Color.magenta;
                            DrawWireCapsule(c.transform.position, c.transform.rotation, c.radius, c.height, c.axis, drawCol);
                        }
					}
                }
				// always writes screen text when in edit mode or a collider is selected for editing
				if (activeEdit || editMode)
				{
					//large fixed text on the scene view 
					Handles.BeginGUI();
					string lockString = ActiveEditorTracker.sharedTracker.isLocked ? "Locked" : "Unlocked";
					string modeString = colliderManager.manipulatorArray[(int)colliderManager.manipulator];
					string displayString = "Inspector Status: " + lockString + "\nSelected Collider: " + selectedName + "\nMode: " + modeString;

					GUI.Label(new Rect(55, 7, 1000, 1000), displayString, colliderManagerStyles.sceneLabelText);
					Handles.EndGUI();
				}
            }
        }


        public override void OnInspectorGUI()
		{
            if (colliderManager.abstractedCapsuleColliders == null) CreateAbstractColliders();            
            //if (currentCollider == null) return;

            if (editModeEnable == null) InitIcons();
            if (colliderManagerStyles == null) colliderManagerStyles = new Styles();

            baseBackground = GUI.backgroundColor;
            base.OnInspectorGUI();
            //OnColliderInspectorGUI();

            DrawEditAssistBlock();
            DrawColliderSelectionBlock();
            DrawStoreControls();

            if (resetAfterGUI)
            {
                // optional: deselect the collider for editing
                bool deSelectChar = false;
                if (deSelectChar)
                {
                    DeSelectColliderForEdit();
                }

                // reset the collider to the cached values
                colliderManager.ResetColliderFromCache();
                
                SceneView.RepaintAll();
                resetAfterGUI = false;
            }

            if (recallAfterGUI)
            {
                PhysicsSettingsStore.RecallAbstractColliderSettings(colliderManager, false);
                recallAfterGUI = false;
            }
        }
		
		public void OnColliderInspectorGUI()
		{
			

			Color background = GUI.backgroundColor;

            //GUILayout.Space(10f);

			//GUILayout.Label("Adjust Colliders", EditorStyles.boldLabel);

			//GUILayout.Space(10f);
			
            //GUI.backgroundColor = editMode ?  Color.Lerp(background, Color.green, 0.9f) : background;
            //GUILayout.BeginVertical(EditorStyles.helpBox);
			//GUI.backgroundColor = background;

			// addition of new capsule focus commands

			OnColliderControlGUI();

            // end of addition of new capsule focus commands

            /*
            // custom collider adjuster			
            GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Collider", GUILayout.Width(LABEL_WIDTH));
			if (EditorGUILayout.DropdownButton(
				new GUIContent(currentCollider.name),
				FocusType.Passive
				))
			{
				GenericMenu menu = new GenericMenu();
				foreach (ColliderSettings c in colliderManager.settings)
				{
					menu.AddItem(new GUIContent(c.name), c == currentCollider, SelectCurrentCollider, c);
				}
				menu.ShowAsContext();
			}
			GUILayout.EndHorizontal();


			GUILayout.Space(8f);

			EditorGUI.BeginChangeCheck();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Radius", GUILayout.Width(LABEL_WIDTH));
			currentCollider.radiusAdjust = EditorGUILayout.Slider(currentCollider.radiusAdjust, -0.1f, 0.1f);
			GUILayout.EndHorizontal();

			if (currentCollider.collider.GetType() == typeof(CapsuleCollider))
			{
				GUILayout.BeginHorizontal();
				GUILayout.Space(GUTTER);
				GUILayout.Label("Height", GUILayout.Width(LABEL_WIDTH));
				currentCollider.heightAdjust = EditorGUILayout.Slider(currentCollider.heightAdjust, -0.1f, 0.1f);
				GUILayout.EndHorizontal();
			}

			GUILayout.Space(8f);

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("X (loc)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.xAdjust = EditorGUILayout.Slider(currentCollider.xAdjust, -0.1f, 0.1f);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Y (loc)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.yAdjust = EditorGUILayout.Slider(currentCollider.yAdjust, -0.1f, 0.1f);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Z (loc)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.zAdjust = EditorGUILayout.Slider(currentCollider.zAdjust, -0.1f, 0.1f);
			GUILayout.EndHorizontal();

			GUILayout.Space(8f);

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("X (rot)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.xRotate = EditorGUILayout.Slider(currentCollider.xRotate, -90f, 90f);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Y (rot)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.yRotate = EditorGUILayout.Slider(currentCollider.yRotate, -90f, 90f);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Z (rot)", GUILayout.Width(LABEL_WIDTH));
			currentCollider.zRotate = EditorGUILayout.Slider(currentCollider.zRotate, -90f, 90f);
			GUILayout.EndHorizontal();

			GUILayout.Space(8f);

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("Symetrical", GUILayout.Width(LABEL_WIDTH));
			symmetrical = EditorGUILayout.Toggle(symmetrical);
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("", GUILayout.Width(LABEL_WIDTH));
			if (GUILayout.Button("Reset", GUILayout.Width(80f)))
			{
				currentCollider.Reset();
				if (symmetrical) UpdateSymmetrical(SymmetricalUpdateType.Reset);
			}
			GUILayout.Space(10f);
			if (GUILayout.Button("Set", GUILayout.Width(80f)))
			{
				currentCollider.FetchSettings();
				if (symmetrical) UpdateSymmetrical(SymmetricalUpdateType.Fetch);
			}
			GUILayout.EndHorizontal();
			GUILayout.Space(10f);
			GUILayout.BeginHorizontal();
			GUILayout.Space(GUTTER);
			GUILayout.Label("", GUILayout.Width(LABEL_WIDTH));			
			if (GUILayout.Button("Select", GUILayout.Width(80f)))
            {
				Selection.activeObject = currentCollider.collider;
            }
			GUILayout.EndHorizontal();

			if (EditorGUI.EndChangeCheck())
			{
				currentCollider.Update();
				if (symmetrical) UpdateSymmetrical(SymmetricalUpdateType.Update);
			}
			
			*/
            //GUILayout.EndVertical();
            GUI.backgroundColor = background;

            GUILayout.Space(10f);

			
            EditorGUILayout.HelpBox("If changing the colliders directly, use the Rebuild Settings button to update to the new Collider settings.", MessageType.Info, true);

			GUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			if (GUILayout.Button("Rebuild Settings", GUILayout.Width(BUTTON_WIDTH)))
			{
				colliderManager.RefreshData();
				InitCurrentCollider(CURRENT_COLLIDER_NAME);
			}
			GUILayout.FlexibleSpace();
			GUILayout.EndHorizontal();

			GUILayout.Space(10f);

			EditorGUILayout.HelpBox("Settings can be saved in play mode and reloaded after play mode ends.", MessageType.Info, true);

			GUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUI.backgroundColor = Color.Lerp(background, Color.red, 0.25f);
			if (GUILayout.Button("Save Settings", GUILayout.Width(BUTTON_WIDTH)))
			{
				PhysicsSettingsStore.SaveColliderSettings(colliderManager);
			}
			GUI.backgroundColor = background;
			GUILayout.Space(10f);			
			GUI.backgroundColor = Color.Lerp(background, Color.yellow, 0.25f);
			if (GUILayout.Button("Recall Settings", GUILayout.Width(BUTTON_WIDTH)))
			{
				PhysicsSettingsStore.RecallColliderSettings(colliderManager);
			}
			GUI.backgroundColor = background;			
			GUILayout.FlexibleSpace();
			GUILayout.EndHorizontal();

			GUILayout.Space(10f);

			GUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			if (Application.isPlaying) GUI.enabled = false;
			GUI.backgroundColor = Color.Lerp(background, Color.cyan, 0.25f);
			if (GUILayout.Button("Apply to Prefab", GUILayout.Width(BUTTON_WIDTH)))
			{
				UpdatePrefab(colliderManager);
			}
			GUI.enabled = true;
			GUI.backgroundColor = background;
			GUILayout.FlexibleSpace();
			GUILayout.EndHorizontal();			

			GUILayout.Space(10f);

			GUILayout.BeginHorizontal();
			GUILayout.Label("Cloth Meshes", EditorStyles.boldLabel);
			GUILayout.BeginVertical();
			
			GUI.backgroundColor = Color.Lerp(background, Color.green, 0.25f);
			foreach (GameObject clothMesh in colliderManager.clothMeshes)
            {
				GUILayout.BeginHorizontal();
				GUILayout.FlexibleSpace();
				if (GUILayout.Button(clothMesh.name, GUILayout.Width(160f)))
				{
					Selection.activeObject = clothMesh;
				}
				GUILayout.FlexibleSpace();
				GUILayout.EndHorizontal();
				GUILayout.Space(4f);
			}
			GUI.backgroundColor = background;
			GUILayout.EndVertical();
			GUILayout.EndHorizontal();
		}

        // tracking logic:
        // animplayer bone tracking implicitly selects an object and frames the sceneview with it
        // this always deselects the collider manager
        //
        // have a tracking capability in the collider manager 
        // this should do the following:
        // - when on should highlight the collider manager with a red box or something conspicuous 
        // - prevent bone tracking in the anim player from working
        // - lock the inspector to the collider manager
        // - fold in all components but the collider manager (possible?)
        // - select the collider object to track & frame that object for active scene camera following
        // - manually draw all the collider gizmos 
        // - make it so play mode can be entered smoothly


		private void DrawEditAssistBlock()
		{
            GUILayout.Space(10f);
            GUILayout.Label("Edit Assist Mode", EditorStyles.boldLabel);
            GUILayout.Space(10f);
            GUI.backgroundColor = editMode ? Color.Lerp(baseBackground, Color.green, 0.9f) : baseBackground;
            GUILayout.BeginVertical(EditorStyles.helpBox);
            GUI.backgroundColor = baseBackground;

            GUILayout.BeginVertical();
            GUILayout.Space(10f);

            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            GUILayout.BeginVertical();
            GUILayout.FlexibleSpace();
            EditorGUI.BeginChangeCheck();

            // Icons from <a target="_blank" href="https://icons8.com/icon/1CDroSc0Up0D/wrench">Wrench</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>

            editMode = ActiveEditorTracker.sharedTracker.isLocked;
            //string lookIcon = locked ? "d_SceneViewVisibility" : "ViewToolOrbit";
            //Texture2D lookIconImage = (Texture2D)EditorGUIUtility.IconContent(lookIcon).image;
            Texture2D lookIconImage = editMode ? editModeDisable : editModeEnable;
            if (GUILayout.Button(new GUIContent(lookIconImage, (editMode ? "EXIT from" : "ENTER") + " edit assist mode.\n" + (editMode ? "This will UNLOCK the inspctor and reselect the character - drawing all the default gizmos" : "This will LOCK the inspector and deselect the character - showing only the gizmos of editable colliders and preventing loss of focus on the character.")), GUILayout.Width(48f), GUILayout.Height(48f)))
            {
                if (!editMode)
                {
                    SetEditAssistMode();
                }
                else
                {
                    UnSetEditAssistMode();
                }
            }
            if (EditorGUI.EndChangeCheck())
            {
                SceneView.RepaintAll();
            }
            GUILayout.FlexibleSpace();
            GUILayout.EndVertical();
            GUIStyle wrap = new GUIStyle(GUI.skin.button);
            wrap.wordWrap = true;
            EditorGUILayout.HelpBox("Edit assist mode will LOCK the inspector to the character and an only draw the gizmos for the editable colliders. This will provide a less cluttered view and avoid loss of character focus causing issues.", MessageType.Info, true);

            GUILayout.Space(10f);
            GUILayout.EndHorizontal();
            GUILayout.EndVertical();

            GUILayout.Space(10f);
            GUILayout.EndVertical(); //(EditorStyles.helpBox);
        }

        private void SetEditAssistMode()
        {
            editMode = true;
            if (colliderManager != null)
            {
                if (colliderManager.selectedAbstractCapsuleCollider != null)
                {
                    if (colliderManager.selectedAbstractCapsuleCollider.transform != null)
                        FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
                }
            }
            Selection.activeObject = colliderManager.gameObject;
            ActiveEditorTracker.sharedTracker.isLocked = editMode;
            ActiveEditorTracker.sharedTracker.ForceRebuild();
            SetGizmos();
            Selection.activeObject = null;
            SceneView.RepaintAll();
        }

        private void UnSetEditAssistMode()
        {
            // optional: deselect the collider for editing
            bool deSelectChar = false;
            if (deSelectChar)
            {
                DeSelectColliderForEdit();
            }
            
            editMode = false;            
            ActiveEditorTracker.sharedTracker.isLocked = false;
            ActiveEditorTracker.sharedTracker.ForceRebuild();
            ResetGizmos();
            Selection.activeObject = colliderManager.gameObject;
            SceneView.RepaintAll();
        }

		private void DrawColliderSelectionBlock()
		{
            GUILayout.Space(10f);
            GUILayout.Label("Adjust Colliders", EditorStyles.boldLabel);
            GUILayout.Space(10f);
            GUI.backgroundColor = editMode ? Color.Lerp(baseBackground, Color.green, 0.9f) : baseBackground;
            GUILayout.BeginVertical(EditorStyles.helpBox);
            GUI.backgroundColor = baseBackground;

            GUILayout.BeginVertical();
            GUILayout.Space(10f);
            if (colliderManager.abstractedCapsuleColliders != null)
            {
                foreach (ColliderManager.AbstractCapsuleCollider c in colliderManager.abstractedCapsuleColliders)
                {
                    bool active = (c == colliderManager.selectedAbstractCapsuleCollider);
                    GUILayout.BeginVertical();

                    GUILayout.BeginHorizontal();
                    GUILayout.Space(10f);

                    if (GUILayout.Button(c.name, (active ? colliderManagerStyles.currentButton : colliderManagerStyles.normalButton), GUILayout.MaxWidth(250f)))
                    {
                        SelectColliderForEdit(c);
                    }
                    GUILayout.Space(10f);
                    GUILayout.EndHorizontal();

                    if (active)
                    {
                        GUILayout.Space(2f);
                        DrawEditModeControls();
                    }

                    GUILayout.EndVertical();
                    if (active)
                        GUILayout.Space(2f);
                }
            }
            GUILayout.Space(10f);

            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            EditorGUI.BeginChangeCheck();
            colliderManager.transformSymmetrically = GUILayout.Toggle(colliderManager.transformSymmetrically, new GUIContent("Symmetrical Transformation"));
            if (EditorGUI.EndChangeCheck())
            {
                SceneView.RepaintAll();
                if (colliderManager.selectedAbstractCapsuleCollider != null)
                {
                    colliderManager.mirrorImageAbstractCapsuleCollider = DetermineMirrorImageCollider(colliderManager.selectedAbstractCapsuleCollider);
                    FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
                }
            }
            GUILayout.Space(10f);
            EditorGUI.BeginChangeCheck();
            colliderManager.frameSymmetryPair = GUILayout.Toggle(colliderManager.frameSymmetryPair, new GUIContent("Frame Pair"));
            if (EditorGUI.EndChangeCheck())
            {
                SceneView.RepaintAll();
                if (colliderManager.selectedAbstractCapsuleCollider != null)
                {
                    colliderManager.mirrorImageAbstractCapsuleCollider = DetermineMirrorImageCollider(colliderManager.selectedAbstractCapsuleCollider);
                    FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
                }
            }

            GUILayout.EndHorizontal();

            GUILayout.Space(10f);
            GUILayout.EndVertical();

            GUILayout.EndVertical();
        }

        private void SelectColliderForEdit(ColliderManager.AbstractCapsuleCollider c)
        {
            //SetGizmos();
            activeEdit = true;
            if (!SceneView.lastActiveSceneView.drawGizmos && !editMode)
                SceneView.lastActiveSceneView.drawGizmos = true;
            colliderManager.selectedAbstractCapsuleCollider = c;
            colliderManager.mirrorImageAbstractCapsuleCollider = DetermineMirrorImageCollider(c);
            colliderManager.CacheCollider(colliderManager.selectedAbstractCapsuleCollider, colliderManager.mirrorImageAbstractCapsuleCollider);
            
            if (Reallusion.Import.AnimPlayerGUI.IsPlayerShown() && Reallusion.Import.AnimPlayerGUI.isTracking)
            {
                GameObject go = Reallusion.Import.AnimPlayerGUI.lastTracked;
                editMode = true;
                FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
                Selection.activeObject = colliderManager.gameObject;
                ActiveEditorTracker.sharedTracker.isLocked = editMode;
                ActiveEditorTracker.sharedTracker.ForceRebuild();
                Selection.activeObject = go;
            }
            else
            {
                FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
            }
            
            SceneView.RepaintAll();
        }

        private void DeSelectColliderForEdit()
        {
            colliderManager.selectedAbstractCapsuleCollider = null;
            colliderManager.mirrorImageAbstractCapsuleCollider = null;
            activeEdit = false;
            SceneView.RepaintAll();
        }

        private void OnColliderControlGUI()
        {
            //if (currentCollider == null) return;

            Color background = GUI.backgroundColor;

            GUILayout.Space(10f);
            GUILayout.Label("Edit Assist Mode", EditorStyles.boldLabel);
            GUILayout.Space(10f);
            GUI.backgroundColor = editMode ? Color.Lerp(background, Color.green, 0.9f) : background;
            GUILayout.BeginVertical(EditorStyles.helpBox);
            GUI.backgroundColor = background;

            GUILayout.BeginVertical();
            GUILayout.Space(10f);
            
            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            GUILayout.BeginVertical();
            GUILayout.FlexibleSpace();
            EditorGUI.BeginChangeCheck();

            // Icons from <a target="_blank" href="https://icons8.com/icon/1CDroSc0Up0D/wrench">Wrench</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>

            editMode = ActiveEditorTracker.sharedTracker.isLocked;
            //string lookIcon = locked ? "d_SceneViewVisibility" : "ViewToolOrbit";
            //Texture2D lookIconImage = (Texture2D)EditorGUIUtility.IconContent(lookIcon).image;
            Texture2D lookIconImage = editMode ? editModeDisable : editModeEnable;
            if (GUILayout.Button(new GUIContent(lookIconImage, (editMode ? "EXIT from" : "ENTER") + " edit assist mode.\n" + (editMode ? "This will UNLOCK the inspctor and reselect the character - drawing all the default gizmos" : "This will LOCK the inspector and deselect the character - showing only the gizmos of editable colliders and preventing loss of focus on the character.")), GUILayout.Width(48f), GUILayout.Height(48f)))
            {
                if (!editMode)
                {
                    editMode = true;
					if (colliderManager.selectedAbstractCapsuleCollider != null)
						FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
                    Selection.activeObject = colliderManager.gameObject;
                    ActiveEditorTracker.sharedTracker.isLocked = editMode;
                    ActiveEditorTracker.sharedTracker.ForceRebuild();
					SetGizmos();
                    Selection.activeObject = null;
                }
                else
                {
                    editMode = false;
					activeEdit = false;
					colliderManager.selectedAbstractCapsuleCollider = null;
					colliderManager.mirrorImageAbstractCapsuleCollider = null;
                    ActiveEditorTracker.sharedTracker.isLocked = editMode;
                    ActiveEditorTracker.sharedTracker.ForceRebuild();
					ResetGizmos();
                    Selection.activeObject = colliderManager.gameObject;
                }
            }            
            if (EditorGUI.EndChangeCheck())
            {
                SceneView.RepaintAll();
            }
            GUILayout.FlexibleSpace();
			GUILayout.EndVertical();
			GUIStyle wrap = new GUIStyle(GUI.skin.button);
			wrap.wordWrap = true;            
            EditorGUILayout.HelpBox("Edit assist mode will LOCK the inspector to the character and an only draw the gizmos for the editable colliders. This will provide a less cluttered view and avoid loss of character focus causing issues.", MessageType.Info, true);

            GUILayout.Space(10f);
            GUILayout.EndHorizontal();
            GUILayout.EndVertical();

            GUILayout.Space(10f);
            GUILayout.EndVertical(); //(EditorStyles.helpBox);

            GUILayout.Space(10f);
            GUILayout.Label("Adjust Colliders", EditorStyles.boldLabel);
            GUILayout.Space(10f);
            GUI.backgroundColor = editMode ? Color.Lerp(background, Color.green, 0.9f) : background;
            GUILayout.BeginVertical(EditorStyles.helpBox);
            GUI.backgroundColor = background;

            GUILayout.BeginVertical();
            GUILayout.Space(10f);
			if (colliderManager.abstractedCapsuleColliders != null)
			{
				foreach (ColliderManager.AbstractCapsuleCollider c in colliderManager.abstractedCapsuleColliders)
				{
                    bool active = (c == colliderManager.selectedAbstractCapsuleCollider);
                    GUILayout.BeginVertical();

                    GUILayout.BeginHorizontal();
					GUILayout.Space(10f);

                    if (GUILayout.Button(c.name, (active ? colliderManagerStyles.currentButton : colliderManagerStyles.normalButton), GUILayout.MaxWidth(250f)))
					{
						//SetGizmos();
						activeEdit = true;
						if (!SceneView.lastActiveSceneView.drawGizmos && !editMode)
							SceneView.lastActiveSceneView.drawGizmos = true;
                        colliderManager.selectedAbstractCapsuleCollider = c;
						colliderManager.mirrorImageAbstractCapsuleCollider = DetermineMirrorImageCollider(c);
                        colliderManager.CacheCollider(colliderManager.selectedAbstractCapsuleCollider, colliderManager.mirrorImageAbstractCapsuleCollider);

                        if (Reallusion.Import.AnimPlayerGUI.IsPlayerShown() && Reallusion.Import.AnimPlayerGUI.isTracking)
						{
							GameObject go = Reallusion.Import.AnimPlayerGUI.lastTracked;
							editMode = true;
							FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
							Selection.activeObject = colliderManager.gameObject;
							ActiveEditorTracker.sharedTracker.isLocked = editMode;
							ActiveEditorTracker.sharedTracker.ForceRebuild();
							Selection.activeObject = go;
						}
						else
						{
							FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);							
                        }
						SceneView.RepaintAll();
					}
                    GUILayout.Space(10f);
                    GUILayout.EndHorizontal();

                    if (active)
					{
                        GUILayout.Space(2f);
                        DrawEditModeControls();
					}

                    GUILayout.EndVertical();
                    if (active)
						GUILayout.Space(2f);
				}
			}
            GUILayout.Space(10f);

            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            EditorGUI.BeginChangeCheck();
            colliderManager.transformSymmetrically = GUILayout.Toggle(colliderManager.transformSymmetrically, new GUIContent("Symmetrical Transformation"));
            if (EditorGUI.EndChangeCheck())
            {
                SceneView.RepaintAll();
				if (colliderManager.selectedAbstractCapsuleCollider != null)
				{
					colliderManager.mirrorImageAbstractCapsuleCollider = DetermineMirrorImageCollider(colliderManager.selectedAbstractCapsuleCollider);
					FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
				}
            }
            GUILayout.Space(10f);
            EditorGUI.BeginChangeCheck();
            colliderManager.frameSymmetryPair = GUILayout.Toggle(colliderManager.frameSymmetryPair, new GUIContent("Frame Pair"));
            if (EditorGUI.EndChangeCheck())
            {
                SceneView.RepaintAll();
                if (colliderManager.selectedAbstractCapsuleCollider != null)
                {
                    colliderManager.mirrorImageAbstractCapsuleCollider = DetermineMirrorImageCollider(colliderManager.selectedAbstractCapsuleCollider);
                    FocusPosition(colliderManager.selectedAbstractCapsuleCollider.transform.position);
                }
            }

            GUILayout.EndHorizontal();

            GUILayout.Space(10f);
            GUILayout.EndVertical();
			

            GUILayout.EndVertical();
        }

		public void DrawEditModeControls()
		{
            GUILayout.BeginHorizontal(GUILayout.MaxWidth(270f));
            GUILayout.Space(10f);
            
            GUIStyle style = (colliderManager.manipulator == ColliderManager.ManipulatorType.position ? colliderManagerStyles.currentButton : colliderManagerStyles.normalButton);
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("d_MoveTool on").image, "Transform position tool"), style, GUILayout.Width(30f)))
            {
                colliderManager.manipulator = ColliderManager.ManipulatorType.position;
                SceneView.RepaintAll();
            }
            //GUILayout.Space(0f);
            style = (colliderManager.manipulator == ColliderManager.ManipulatorType.rotation ? colliderManagerStyles.currentButton : colliderManagerStyles.normalButton);
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("d_RotateTool On").image, "Transform rotation tool"), style, GUILayout.Width(30f)))
            {
                colliderManager.manipulator = ColliderManager.ManipulatorType.rotation;
                SceneView.RepaintAll();
            }
            //GUILayout.Space(0f);
            style = (colliderManager.manipulator == ColliderManager.ManipulatorType.scale ? colliderManagerStyles.currentButton : colliderManagerStyles.normalButton);
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("ScaleTool On").image, "Transform scale tool"), style, GUILayout.Width(30f)))
            {
                colliderManager.manipulator = ColliderManager.ManipulatorType.scale;
                SceneView.RepaintAll();
            }

            GUILayout.FlexibleSpace();

            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("d_TreeEditor.Trash").image, "Undo Changes"), colliderManagerStyles.normalButton, GUILayout.Width(30f))) // d_clear
            {
                resetAfterGUI = true;
            }
            //GUILayout.Space(0f);
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("d_TreeEditor.Refresh").image, "Reset Collider To Default"), colliderManagerStyles.normalButton, GUILayout.Width(30f))) // d_clear
            {
                colliderManager.ResetSingleAbstractCollider(PhysicsSettingsStore.RecallAbstractColliderSettings(colliderManager, true), colliderManager.selectedAbstractCapsuleCollider.name, colliderManager.transformSymmetrically);
                //resetAfterGUI = true;
            }
            //GUILayout.Space(0f);
            if (GUILayout.Button(new GUIContent(EditorGUIUtility.IconContent("d_clear").image, "Only Deselect Collider"), colliderManagerStyles.normalButton, GUILayout.Width(30f)))
            {
                DeSelectColliderForEdit();                
            }
            GUILayout.Space(10f);
            GUILayout.EndHorizontal();
        }

        public void DrawStoreControls()
        {
            GUILayout.Space(10f);
            GUILayout.Label("Save and Recall", EditorStyles.boldLabel);
            GUILayout.Space(10f);
            GUI.backgroundColor = editMode ? Color.Lerp(baseBackground, Color.green, 0.9f) : baseBackground;
            GUILayout.BeginVertical(EditorStyles.helpBox);
            GUI.backgroundColor = baseBackground;

            GUILayout.BeginVertical();
            GUILayout.Space(10f);

            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            if (GUILayout.Button("Save"))
            {
                PhysicsSettingsStore.SaveAbstractColliderSettings(colliderManager);
            }

            GUILayout.Space(10f);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            if (GUILayout.Button("Recall"))
            {
                //colliderManager.abstractedCapsuleColliders = PhysicsSettingsStore.RecallAbstractColliderSettings(colliderManager);
                //recallAfterGUI = true;  
                colliderManager.ResetAbstractColliders(PhysicsSettingsStore.RecallAbstractColliderSettings(colliderManager, false));
            }

            GUILayout.Space(10f);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Space(10f);

            if (GUILayout.Button("Default"))
            {
                //colliderManager.abstractedCapsuleColliders = PhysicsSettingsStore.RecallAbstractColliderSettings(colliderManager);
                //recallAfterGUI = true;
                colliderManager.ResetAbstractColliders(PhysicsSettingsStore.RecallAbstractColliderSettings(colliderManager, true));
            }

            GUILayout.Space(10f);
            GUILayout.EndHorizontal();


            GUILayout.Space(10f);
            GUILayout.EndVertical();

            GUILayout.EndVertical();// (EditorStyles.helpBox);

        }

		
        public void UpdatePrefab(Object component)
		{
			WindowManager.HideAnimationPlayer(true);
			WindowManager.HideAnimationRetargeter(true);

			GameObject prefabRoot = PrefabUtility.GetOutermostPrefabInstanceRoot(component);			
			if (prefabRoot)
			{									
				// reset collider states
				ColliderManager colliderManager = prefabRoot.GetComponentInChildren<ColliderManager>();
				if (colliderManager)
				{
					foreach (ColliderSettings cs in colliderManager.settings)
					{
						cs.Reset(true);						
					}
				}

				// save prefab asset
				PrefabUtility.ApplyPrefabInstance(prefabRoot, InteractionMode.UserAction);
			}
		}

		enum SymmetricalUpdateType { None, Update, Fetch, Reset }
        
		private void UpdateSymmetrical(SymmetricalUpdateType type)
		{
			string name = currentCollider.name;

			string boneName = name.Remove(name.IndexOf("_Capsule"));
			string symName = null;
			//Debug.Log(boneName);

			if (boneName.Contains("_L_"))
			{
				symName = boneName.Replace("_L_", "_R_");
			}
			else if (boneName.Contains("_R_"))
			{
				symName = boneName.Replace("_R_", "_L_");
			}
			else if (boneName.Contains("_Hip"))
			{
				symName = boneName;				
			}				

			if (!string.IsNullOrEmpty(symName))
			{
				foreach (ColliderSettings cs in colliderManager.settings)
				{
					if (cs != currentCollider && cs.name.StartsWith(symName))
					{
						if (type == SymmetricalUpdateType.Update)
						{
							cs.MirrorX(currentCollider);
							cs.Update();
						}
						else if (type == SymmetricalUpdateType.Reset)
						{
							cs.Reset();
						}
						else if (type == SymmetricalUpdateType.Fetch)
						{
							cs.FetchSettings();
						}
					}
				}
			}

			symName = null;

			if (name == "CC_Base_NeckTwist01_Capsule(1)")
			{
				symName = "CC_Base_NeckTwist01_Capsule(2)";
			}
			else if (name == "CC_Base_NeckTwist01_Capsule(2)")
			{
				symName = "CC_Base_NeckTwist01_Capsule(1)";
			}

			if (!string.IsNullOrEmpty(symName))
			{
				foreach (ColliderSettings cs in colliderManager.settings)
				{
					if (cs != currentCollider && cs.name.StartsWith(symName))
					{
						if (type == SymmetricalUpdateType.Update)
						{
							cs.MirrorZ(currentCollider);
							cs.Update();
						}
						else if (type == SymmetricalUpdateType.Reset)
						{
							cs.Reset();
						}
						else if (type == SymmetricalUpdateType.Fetch)
						{
							cs.FetchSettings();
						}
					}
				}
			}
		}

		private void SelectCurrentCollider(object sel)
		{
			currentCollider = (ColliderSettings)sel;
			if (currentCollider != null)
			{
				CURRENT_COLLIDER_NAME = currentCollider.name;
			}
		}

        public static void DrawWireCapsule(Vector3 _pos, Quaternion _rot, float _radius, float _height, ColliderManager.ColliderAxis _axis, Color _color = default(Color))
        {
			if (_axis == ColliderManager.ColliderAxis.z)
				_rot = _rot * Quaternion.AngleAxis(90f, Vector3.right);
            if (_color != default(Color))
                Handles.color = _color;
            Matrix4x4 angleMatrix = Matrix4x4.TRS(_pos, _rot, Handles.matrix.lossyScale);
            using (new Handles.DrawingScope(angleMatrix))
            {
                var pointOffset = (_height - (_radius * 2)) / 2;

                //draw sideways
                Handles.DrawWireArc(Vector3.up * pointOffset, Vector3.left, Vector3.back, -180, _radius);
                Handles.DrawLine(new Vector3(0, pointOffset, -_radius), new Vector3(0, -pointOffset, -_radius));
                Handles.DrawLine(new Vector3(0, pointOffset, _radius), new Vector3(0, -pointOffset, _radius));
                Handles.DrawWireArc(Vector3.down * pointOffset, Vector3.left, Vector3.back, 180, _radius);
                //draw frontways
                Handles.DrawWireArc(Vector3.up * pointOffset, Vector3.back, Vector3.left, 180, _radius);
                Handles.DrawLine(new Vector3(-_radius, pointOffset, 0), new Vector3(-_radius, -pointOffset, 0));
                Handles.DrawLine(new Vector3(_radius, pointOffset, 0), new Vector3(_radius, -pointOffset, 0));
                Handles.DrawWireArc(Vector3.down * pointOffset, Vector3.back, Vector3.left, -180, _radius);
                //draw center
                Handles.DrawWireDisc(Vector3.up * pointOffset, Vector3.up, _radius);
                Handles.DrawWireDisc(Vector3.down * pointOffset, Vector3.up, _radius);

            }
        }

        public static Texture2D TextureColor(Color color)
        {
            const int size = 32;
            Texture2D texture = new Texture2D(size, size);
            Color[] pixels = texture.GetPixels();
            for (int i = 0; i < pixels.Length; i++)
            {
                pixels[i] = color;
            }
            texture.SetPixels(pixels);
            texture.Apply(true);
            return texture;
        }

        public void FocusPosition(Vector3 pos)
        {
			Bounds framingBounds;
            float mult = 0.35f;

            //if (colliderManager.transformSymmetrically && colliderManager.frameSymmetryPair && colliderManager.mirrorImageAbstractCapsuleCollider != null)
            if (colliderManager.transformSymmetrically && colliderManager.frameSymmetryPair && !ColliderManager.AbstractCapsuleCollider.IsNullOrEmpty(colliderManager.mirrorImageAbstractCapsuleCollider))
            {
                Vector3 diff = colliderManager.mirrorImageAbstractCapsuleCollider.transform.position + colliderManager.selectedAbstractCapsuleCollider.transform.position;
                Vector3 mid = diff / 2;
                float mag = diff.magnitude;

                if (mag > 2)
                    mult = mag * 0.15f;
                else
                    mult = mag * 0.4f;

                framingBounds = new Bounds(mid, Vector3.one * mult);
            }
            else
                framingBounds = new Bounds(pos, Vector3.one * mult);

            SceneView.lastActiveSceneView.Frame(framingBounds, false);
            SceneView.lastActiveSceneView.rotation = Quaternion.Euler(180f, 0f, 180f);
        }

        private ColliderManager.AbstractCapsuleCollider DetermineMirrorImageCollider(ColliderManager.AbstractCapsuleCollider collider)
        {
            if (!colliderManager.transformSymmetrically) { return null; }

            if (colliderManager.DetermineMirrorImageColliderName(collider.name, out string mirrorName, out colliderManager.selectedMirrorPlane))
                return colliderManager.abstractedCapsuleColliders.Find(x => x.name == mirrorName);
            else
                return null;
        }

        public void SetGizmos()
		{
            // turn on gizmo display (if off) and in 2022.1 or above can supress the drawing
            // of certain gizmos and icons for a cleaner scene
            cachedGizmoState = new GizmoState();
            //ColliderManager.GizmoState state = colliderManager.cachedGizmoState;
            cachedGizmoState.gizmosEnabled = SceneView.lastActiveSceneView.drawGizmos;
            if (!cachedGizmoState.gizmosEnabled)
				SceneView.lastActiveSceneView.drawGizmos = true;

#if UNITY_2022_1_OR_NEWER
			colliderManager.hasGizmoUtility = true;
            bool gizmoState = false;
			bool iconState = false;
            Component[] components = colliderManager.GetComponentsInChildren<Component>();
			List<Type> usedTypes = new List<Type>();
            foreach (var component in components)
            {
                // we only need to set the GizmoInfo once per Type so can discard further instances of that Type
                if (!usedTypes.Contains(component.GetType()))
				{
                    usedTypes.Add(component.GetType());
                    if (GizmoUtility.TryGetGizmoInfo(component.GetType(), out GizmoInfo info))
					{
						if (colliderManager.gizmoNames.Contains(info.name))
						{
							if (info.hasGizmo)
							{
								gizmoState = info.gizmoEnabled;
								info.gizmoEnabled = false;
								//Debug.Log("Gizmo Name: " + info.name + " Has state: " + gizmoState);
							}

							if (info.hasIcon)
							{
								iconState = info.iconEnabled;
								info.iconEnabled = false;
								//Debug.Log("Icon Name: " + info.name + " Has state: " + iconState);
							}
							GizmoUtility.ApplyGizmoInfo(info);

							if (info.name == "CapsuleCollider") { cachedGizmoState.capsuleEnabled = gizmoState; }
							else if (info.name == "Cloth") { cachedGizmoState.clothEnabled = gizmoState; }
							else if (info.name == "SphereCollider") { cachedGizmoState.sphereEnabled = gizmoState; }
							else if (info.name == "BoxCollider") { cachedGizmoState.boxEnabled = gizmoState; }
							else if (info.name == "MagicaCapsuleCollider") { cachedGizmoState.magicaCapsuleEnabled = gizmoState; cachedGizmoState.magicaCapsuleIconEnabled = iconState; }
							else if (info.name == "MagicaCloth") { cachedGizmoState.magicaClothEnabled = gizmoState; cachedGizmoState.magicaClothIconEnabled = iconState; }
							else if (info.name == "MagicaSphereCollider") { cachedGizmoState.magicaSphereEnabled = gizmoState; cachedGizmoState.magicaSphereIconEnabled = iconState; }
							else if (info.name == "MagicaPlaneCollider") { cachedGizmoState.magicaPlaneEnabled = gizmoState; cachedGizmoState.magicaPlaneIconEnabled = iconState; }
						}
					} 
				}
            }
#endif
		}

        public void ResetGizmos()
		{
            if (cachedGizmoState == null) return;
             //ColliderManager.GizmoState state = colliderManager.cachedGizmoState;
            SceneView.lastActiveSceneView.drawGizmos = cachedGizmoState.gizmosEnabled;

#if UNITY_2022_1_OR_NEWER
            bool gizmoState = false;
            bool iconState = false;
            Component[] components = colliderManager.GetComponentsInChildren<Component>();
            List<Type> usedTypes = new List<Type>();
			foreach (var component in components)
			{
				if (!usedTypes.Contains(component.GetType()))
				{
					usedTypes.Add(component.GetType());
					if (GizmoUtility.TryGetGizmoInfo(component.GetType(), out GizmoInfo info))
					{
						if (colliderManager.gizmoNames.Contains(info.name))
						{
							if (info.name == "CapsuleCollider") { gizmoState = cachedGizmoState.capsuleEnabled; }
							else if (info.name == "Cloth") { gizmoState = cachedGizmoState.clothEnabled; }
							else if (info.name == "SphereCollider") { gizmoState = cachedGizmoState.sphereEnabled; }
							else if (info.name == "BoxCollider") { gizmoState = cachedGizmoState.boxEnabled; }
							else if (info.name == "MagicaCapsuleCollider") { gizmoState = cachedGizmoState.magicaCapsuleEnabled; iconState = cachedGizmoState.magicaCapsuleIconEnabled; }
							else if (info.name == "MagicaCloth") { gizmoState = cachedGizmoState.magicaClothEnabled; iconState = cachedGizmoState.magicaClothIconEnabled; }
							else if (info.name == "MagicaSphereCollider") { gizmoState = cachedGizmoState.magicaSphereEnabled; iconState = cachedGizmoState.magicaSphereIconEnabled; }
							else if (info.name == "MagicaPlaneCollider") { gizmoState = cachedGizmoState.magicaPlaneEnabled; iconState = cachedGizmoState.magicaPlaneIconEnabled; }

							if (info.hasGizmo)
							{
								//Debug.Log("Gizmo Name: " + info.name + " Applying state: " + gizmoState);
								info.gizmoEnabled = gizmoState;
							}

							if (info.hasIcon)
							{
								//Debug.Log("Icon Name: " + info.name + " Applying state: " + iconState);
								info.iconEnabled = iconState;
							}
							GizmoUtility.ApplyGizmoInfo(info);
						}
					}
				}
			}
#endif
        }


        [Serializable]
        public class GizmoState
        {
            public bool gizmosEnabled { get; set; }
            public bool capsuleEnabled { get; set; }
            public bool clothEnabled { get; set; }
            public bool sphereEnabled { get; set; }
            public bool boxEnabled { get; set; }
            public bool magicaCapsuleEnabled { get; set; }
            public bool magicaCapsuleIconEnabled { get; set; }
            public bool magicaClothEnabled { get; set; }
            public bool magicaClothIconEnabled { get; set; }
            public bool magicaSphereEnabled { get; set; }
            public bool magicaSphereIconEnabled { get; set; }
            public bool magicaPlaneEnabled { get; set; }
            public bool magicaPlaneIconEnabled { get; set; }
            public float iconSize { get; set; }
            public bool iconsEnabled { get; set; }

            public GizmoState()
            {
                gizmosEnabled = false;
                capsuleEnabled = false;
                clothEnabled = false;
                sphereEnabled = false;
                boxEnabled = false;
                magicaCapsuleEnabled = false;
                magicaCapsuleIconEnabled = false;
                magicaClothEnabled = false;
                magicaClothIconEnabled = false;
                magicaSphereEnabled = false;
                magicaSphereIconEnabled = false;
                magicaPlaneEnabled = false;
                magicaPlaneIconEnabled = false;
                iconSize = 0f;
                iconsEnabled = false;
            }
        }
    }
}






