//
//  supabase.swift
//  cheakin
//
//  Created by Arnav Gupta on 10/1/25.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://pqjcprsjyznopekrrzgp.supabase.co")!,
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxamNwcnNqeXpub3Bla3JyemdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkyOTAxMjQsImV4cCI6MjA3NDg2NjEyNH0.DEaIXeqz81PRqHuo_UAIdxUwkQfXj-oE5c-OGagM094"
)
