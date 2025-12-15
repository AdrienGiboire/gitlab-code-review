class GitlabService
  def initialize
    token = ENV['GITLAB_TOKEN']
    Rails.logger.info "GitlabService using token: #{token[0..10]}... (length: #{token&.length})"
    @client = Gitlab.client(
      endpoint: gitlab_endpoint,
      private_token: token
    )
  end

  def export_merge_request_feedback(mr_url)
    project_path, mr_iid = parse_mr_url(mr_url)

    mr = @client.merge_request(project_path, mr_iid)
    
    # Fetch all discussions with automatic pagination
    discussions = @client.merge_request_discussions(project_path, mr_iid).auto_paginate

    # Build a map of note_id => has_check_mark by fetching all award emojis upfront
    check_marks = build_check_mark_map(discussions, project_path, mr_iid)

    {
      project_path: project_path,
      mr_iid: mr_iid,
      merge_request: format_merge_request(mr),
      feedback: format_discussions(discussions, check_marks)
    }
  end

  def add_reaction_to_note(project_path, mr_iid, note_id, emoji = 'white_check_mark')
    # project, awardable_id (MR iid), awardable_type, note_id, emoji_name
    @client.create_note_award_emoji(project_path, mr_iid, 'merge_request', note_id, emoji)
  end

  private

  def parse_mr_url(url)
    match = url.match(%r{([^/]+/[^/]+)/-/merge_requests/(\d+)})
    raise ArgumentError, 'Invalid GitLab MR URL' unless match

    project_path = match[1]
    mr_iid = match[2].to_i

    [project_path, mr_iid]
  end

  def format_merge_request(mr)
    {
      id: mr.iid,
      title: mr.title,
      author: mr.author.username,
      source_branch: mr.source_branch,
      target_branch: mr.target_branch,
      state: mr.state,
      web_url: mr.web_url
    }
  end

  def build_check_mark_map(discussions, project_path, mr_iid)
    check_marks = {}
    note_ids = []
    
    # Collect all note IDs
    discussions.each do |discussion|
      discussion.notes.each do |note|
        note_ids << note.id unless note.try(:system)
      end
    end

    # Fetch award emojis for each note in parallel using threads
    threads = note_ids.map do |note_id|
      Thread.new do
        begin
          emojis = @client.note_award_emojis(project_path, mr_iid, 'merge_request', note_id)
          has_check = emojis.any? { |emoji| emoji.name == 'white_check_mark' }
          [note_id, has_check]
        rescue => e
          Rails.logger.error "Failed to fetch award emojis for note #{note_id}: #{e.message}"
          [note_id, false]
        end
      end
    end

    # Wait for all threads and build the map
    threads.each do |thread|
      note_id, has_check = thread.value
      check_marks[note_id] = has_check
    end

    check_marks
  end

  def format_discussions(discussions, check_marks)
    feedback = []

    discussions.each do |discussion|
      discussion.notes.each do |note|
        # Skip system notes (merged, assigned, etc.)
        next if note.try(:system)

        position = note.try(:position)
        file = position.try(:new_path) || position.try(:old_path)
        line = position.try(:new_line) || position.try(:old_line)

        feedback << {
          id: note.id,
          discussion_id: discussion.id,
          author: note.author&.username,
          body: note.body,
          file: file,
          line: line,
          has_check_mark: check_marks[note.id] || false
        }
      end
    end

    feedback
  end

  def gitlab_endpoint
    ENV['GITLAB_ENDPOINT'] || 'https://gitlab.com/api/v4'
  end
end
