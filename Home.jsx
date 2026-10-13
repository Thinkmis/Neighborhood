function Home() {
  const [activeCategory, setActiveCategory] = React.useState('All');
  const [searchTerm, setSearchTerm] = React.useState('');
  const [neighborhood, setNeighborhood] = React.useState('All Neighborhoods');

  const [posts, setPosts] = React.useState([
    {
      id: 1,
      author: 'Rahim Ahmed',
      time: '15 minutes ago',
      category: 'Announcements',
      title: 'Scheduled Water Supply Maintenance',
      content: 'Water supply will be temporarily suspended tomorrow from 10:00 AM to 2:00 PM for pipeline maintenance in Block-B.',
      neighborhood: 'Block-B',
      likes: 12,
      comments: 4,
      liked: false
    },
    {
      id: 2,
      author: 'Tanvir Hossain',
      time: '1 hour ago',
      category: 'Lost & Found',
      title: 'Lost Keys with Blue Keychain',
      content: 'I lost my house keys near the community park this afternoon. If found, please contact me via the platform!',
      neighborhood: 'Park View Area',
      likes: 5,
      comments: 2,
      liked: false
    },
    {
      id: 3,
      author: 'Nusrat Jahan',
      time: '3 hours ago',
      category: 'Buy & Sell',
      title: 'Nearly New Mountain Bicycle for Sale',
      content: 'Looking to sell my bicycle in great condition. Price: 4,500 BDT. DM for details.',
      neighborhood: 'Block-A',
      likes: 8,
      comments: 6,
      liked: false
    },
    {
      id: 4,
      author: 'Karim Ullah',
      time: '5 hours ago',
      category: 'Help Requests',
      title: 'Need a reliable electrician urgently',
      content: 'Facing a sudden short-circuit issue in the kitchen switchboard. Can anyone recommend a trusted local electrician nearby?',
      neighborhood: 'Block-C',
      likes: 3,
      comments: 9,
      liked: false
    }
  ]);

  const handleLike = (id) => {
    setPosts(posts.map(post => {
      if (post.id === id) {
        return {
          ...post,
          likes: post.liked ? post.likes - 1 : post.likes + 1,
          liked: !post.liked
        };
      }
      return post;
    }));
  };

  const filteredPosts = posts.filter(post => {
    const matchesCategory = activeCategory === 'All' || post.category === activeCategory;
    const matchesSearch = post.title.toLowerCase().includes(searchTerm.toLowerCase()) || 
                          post.content.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesNeighborhood = neighborhood === 'All Neighborhoods' || post.neighborhood === neighborhood;
    return matchesCategory && matchesSearch && matchesNeighborhood;
  });

  return (
    <div className="neighborly-app">
      {/* Navigation Bar */}
      <nav className="navbar">
        <div className="nav-brand">
          <h2>Neighborly</h2>
          <span>Local Community Platform</span>
        </div>
        <ul className="nav-links">
          <li><a href="#feed" className="active">Home Feed</a></li>
          <li><a href="#services">Local Services</a></li>
          <li><a href="#marketplace">Buy & Sell</a></li>
          <li><a href="#events">Events</a></li>
        </ul>
        <div className="nav-actions">
          <button className="btn-outline">Login</button>
          <button className="btn-primary">Register</button>
        </div>
      </nav>

      {/* Hero Header & Search / Filter Section */}
      <header className="hero-section">
        <h1>Connect with Your Local Neighborhood</h1>
        <p>A trusted digital space where nearby residents communicate, share updates, discover services, and solve local problems together[cite: 1].</p>
        
        <div className="search-filter-bar">
          <input 
            type="text" 
            placeholder="Search announcements, help requests, items..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <select value={neighborhood} onChange={(e) => setNeighborhood(e.target.value)}>
            <option>All Neighborhoods</option>
            <option>Block-A</option>
            <option>Block-B</option>
            <option>Block-C</option>
            <option>Park View Area</option>
          </select>
        </div>
      </header>

      {/* Main Container Layout */}
      <div className="main-container">
        
        {/* Left Sidebar: Category Filters */}
        <aside className="sidebar-left">
          <h3>Categories</h3>
          <ul>
            {['All', 'Announcements', 'Lost & Found', 'Buy & Sell', 'Help Requests', 'Emergency Alerts'].map((category) => (
              <li 
                key={category} 
                className={activeCategory === category ? 'active' : ''}
                onClick={() => setActiveCategory(category)}
              >
                {category}
              </li>
            ))}
          </ul>
        </aside>

        {/* Center: Interactive Community Feed */}
        <main className="feed-section">
          {filteredPosts.length > 0 ? (
            filteredPosts.map(post => (
              <div className="post-card" key={post.id}>
                <div className="post-header">
                  <div className="author-info">
                    <h4>{post.author}</h4>
                    <span>{post.time} • 📍 {post.neighborhood}</span>
                  </div>
                  <span className="post-tag">{post.category}</span>
                </div>
                <div className="post-body">
                  <h3>{post.title}</h3>
                  <p>{post.content}</p>
                </div>
                <div className="post-footer">
                  <button 
                    onClick={() => handleLike(post.id)}
                    style={{ color: post.liked ? '#2b6cb0' : 'inherit' }}
                  >
                    👍 Like ({post.likes})
                  </button>
                  <button>💬 Comment ({post.comments})</button>
                  <button>↗ Share</button>
                </div>
              </div>
            ))
          ) : (
            <div className="post-card" style={{ textAlign: 'center', padding: '2rem' }}>
              <p>No posts found matching your current filter criteria.</p>
            </div>
          )}
        </main>

        {/* Right Sidebar: Emergency Alerts & Services Widget */}
        <aside className="sidebar-right">
          <div className="widget emergency-widget">
            <h3>🚨 Emergency Alerts</h3>
            <p><strong>Gas Inspection:</strong> Titas Gas pipeline safety check scheduled in Block-A tomorrow morning.</p>
          </div>
          <div className="widget services-widget" style={{ marginTop: '1.5rem' }}>
            <h3>🛠️ Trusted Local Services</h3>
            <p>Find verified electricians, plumbers, mechanics, and tutors right in your neighborhood[cite: 2].</p>
            <button className="btn-primary" style={{ width: '100%', marginTop: '0.8rem' }}>View Directory</button>
          </div>
        </aside>

      </div>
    </div>
  );
}