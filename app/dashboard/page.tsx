'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';
import { useAuth } from '@/contexts/auth-context';
import { Newsletter } from '@/types/database';
import Link from 'next/link';

export default function Dashboard() {
  const router = useRouter();
  const { user, isLoading } = useAuth();
  const [newsletters, setNewsletters] = useState<Newsletter[]>([]);
  const [fetchingNewsletters, setFetchingNewsletters] = useState(true);

  // Redirect if not logged in
  useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  // Fetch newsletters
  useEffect(() => {
    const fetchNewsletters = async () => {
      if (!user) return;

      try {
        const { data, error } = await supabase
          .from('newsletters')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', { ascending: false });

        if (error) {
          throw error;
        }

        setNewsletters(data || []);
      } catch (error) {
        console.error('Error fetching newsletters:', error);
      } finally {
        setFetchingNewsletters(false);
      }
    };

    fetchNewsletters();
  }, [user]);

  if (isLoading || !user) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center">
          <p className="text-lg">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen">
      <header className="border-b border-border bg-card shadow-sm">
        <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
          <div className="flex h-16 justify-between">
            <div className="flex">
              <div className="flex flex-shrink-0 items-center">
                <span className="text-xl font-bold">MyLetter</span>
              </div>
              <nav className="ml-6 flex items-center space-x-4">
                <Link
                  href="/dashboard"
                  className="px-3 py-2 text-sm font-medium text-primary"
                >
                  Dashboard
                </Link>
                <Link
                  href="/newsletters"
                  className="px-3 py-2 text-sm font-medium text-muted-foreground hover:text-foreground"
                >
                  Newsletters
                </Link>
                <Link
                  href="/subscribers"
                  className="px-3 py-2 text-sm font-medium text-muted-foreground hover:text-foreground"
                >
                  Subscribers
                </Link>
              </nav>
            </div>
            <div className="flex items-center">
              <button
                onClick={() => supabase.auth.signOut()}
                className="ml-4 px-3 py-2 text-sm font-medium text-muted-foreground hover:text-foreground"
              >
                Sign out
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
        <div className="md:flex md:items-center md:justify-between">
          <div className="min-w-0 flex-1">
            <h2 className="text-2xl font-bold leading-7 sm:truncate sm:text-3xl">
              Welcome back
            </h2>
          </div>
          <div className="mt-4 flex md:ml-4 md:mt-0">
            <Link
              href="/newsletters/new"
              className="ml-3 inline-flex items-center rounded-md bg-primary px-3 py-2 text-sm font-semibold text-primary-foreground shadow-sm hover:bg-primary/90"
            >
              Create newsletter
            </Link>
          </div>
        </div>

        <div className="mt-8">
          <h3 className="text-lg font-medium">Your newsletters</h3>
          
          {fetchingNewsletters ? (
            <p className="mt-4 text-muted-foreground">Loading newsletters...</p>
          ) : newsletters.length === 0 ? (
            <div className="mt-4 rounded-lg border border-dashed border-border p-12 text-center">
              <h3 className="mt-2 text-sm font-semibold">No newsletters</h3>
              <p className="mt-1 text-sm text-muted-foreground">
                Get started by creating a new newsletter.
              </p>
              <div className="mt-6">
                <Link
                  href="/newsletters/new"
                  className="inline-flex items-center rounded-md bg-primary px-3 py-2 text-sm font-semibold text-primary-foreground shadow-sm hover:bg-primary/90"
                >
                  Create newsletter
                </Link>
              </div>
            </div>
          ) : (
            <div className="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {newsletters.map((newsletter) => (
                <div
                  key={newsletter.id}
                  className="rounded-lg border border-border bg-card p-6 shadow-sm"
                >
                  <h4 className="text-lg font-semibold">{newsletter.name}</h4>
                  <p className="mt-2 text-sm text-muted-foreground line-clamp-2">
                    {newsletter.description || 'No description'}
                  </p>
                  <div className="mt-4 flex space-x-3">
                    <Link
                      href={`/newsletters/${newsletter.id}`}
                      className="text-sm font-medium text-primary hover:text-primary/90"
                    >
                      View
                    </Link>
                    <Link
                      href={`/newsletters/${newsletter.id}/edit`}
                      className="text-sm font-medium text-muted-foreground hover:text-foreground"
                    >
                      Edit
                    </Link>
                    <Link
                      href={`/newsletters/${newsletter.id}/letters/new`}
                      className="text-sm font-medium text-muted-foreground hover:text-foreground"
                    >
                      New letter
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="mt-12">
          <h3 className="text-lg font-medium">Recent activity</h3>
          <div className="mt-4 rounded-lg border border-border p-6">
            <p className="text-sm text-muted-foreground">
              You don't have any recent activity.
            </p>
          </div>
        </div>
      </main>
    </div>
  );
}