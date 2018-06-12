# discourse-flexible-add-to-serializer
Easily add custom attributes to the serializer so they can easily be displayed in the site's theme (Discourse forum plugin)

## Requirements
`Admin` > `Settings` > `Users` > `enable names` is checked

## Attributes

### Added Attributes
#### BasicUser
- `name`

#### Post
- `user_info`
  - `location`
  - `created_at`
  - `post_count`

#### TopicListItem
- `last_poster_name`

### Modified Attributes

#### Notification
- `display_username` return user's name
- `username2` return user's name

