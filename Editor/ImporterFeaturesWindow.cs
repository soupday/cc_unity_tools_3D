using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Reallusion.Import
{
    public class ImporterFeaturesWindow : EditorWindow
    {
        static ImporterFeaturesWindow importerFeaturesWindow = null;
        static long lastClosedTime;

        void OnEnable()
        {
            AssemblyReloadEvents.beforeAssemblyReload += Close;
            hideFlags = HideFlags.DontSave;
        }

        void OnDisable()
        {
            AssemblyReloadEvents.beforeAssemblyReload -= Close;
            // When window closes we copy all changes to monoimporters (reimport monoScripts)

            importerFeaturesWindow = null;
        }


        public static bool ShowAtPosition(Rect buttonRect)
        {
            long nowMilliSeconds = System.DateTime.Now.Ticks / System.TimeSpan.TicksPerMillisecond;
            bool justClosed = nowMilliSeconds < lastClosedTime + 50;
            if (!justClosed)
            {
                Event.current.Use();
                if (importerFeaturesWindow == null)
                    importerFeaturesWindow = ScriptableObject.CreateInstance<ImporterFeaturesWindow>();
                else
                {
                    importerFeaturesWindow.Cancel();
                    return false;
                }

                importerFeaturesWindow.Init(buttonRect);
                return true;
            }
            return false;
        }

        void Init(Rect buttonRect)
        {
            // Has to be done before calling Show / ShowWithMode
            buttonRect = GUIUtility.GUIToScreenRect(buttonRect);

            SyncToState();

            
            Vector2 windowSize = new Vector2(120f, 200f);

            ShowAsDropDown(buttonRect, windowSize);
        }

        void Cancel()
        {
            // Undo changes we have done.
            // PerformTemporaryUndoStack must be called before Close() below
            // to ensure that we properly undo changes before closing window.
            //Undo.PerformTemporaryUndoStack();

            Close();
            GUI.changed = true;
            GUIUtility.ExitGUI();
        }

        private void SyncToState()
        {

        }

        void OnGUI()
        {
            //GUIStyle background = new GUIStyle(GUI.skin.window);
            //background.normal.background = TextureColor(Color.white);
            //background.normal.textColor = Color.black * 0.9f;

            //GUILayout.BeginArea(new Rect(0, 0, 120, 200), background);
            //GUI.backgroundColor = Color.yellow;
            GUILayout.BeginHorizontal();
            GUILayout.Label("Itam");
            GUILayout.FlexibleSpace();
            GUILayout.Toggle(true, "");
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("Itam");
            GUILayout.FlexibleSpace();
            GUILayout.Toggle(true, "");
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("Itam");
            GUILayout.FlexibleSpace();
            GUILayout.Toggle(true, "");
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("Itam");
            GUILayout.FlexibleSpace();
            GUILayout.Toggle(true, "");
            GUILayout.EndHorizontal();

            //GUILayout.EndArea();
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

    }
}
